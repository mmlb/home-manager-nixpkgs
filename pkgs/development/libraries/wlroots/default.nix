{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, fetchpatch
, wayland, libGL, wayland-protocols, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, mesa
, libpng, ffmpeg_4, freerdp
}:

stdenv.mkDerivation rec {
  pname = "wlroots";
  version = "unstable-2019-11-13g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "wlroots";
    rev = "cde544de81b3da6368c3f88fe6d08df0b4bc198e";
    sha256 = "1my8hg989n9z9ndp7b1j81p2fvgx04qhrcm1kqjawdlk6yfyj72m";
  };

  patches = [
    # add missing header that changed in mesa-19.2.2
    # https://github.com/swaywm/wlroots/issues/1862
    (fetchpatch {
      url = "https://github.com/swaywm/wlroots/commit/d113e48a2a32542fe6e12f1759f07888364609bf.diff";
      sha256 = "1h09j1gmnzlz4py92a92chgy8xzsd8h8xn5irq9s2hq4cla66h87";
    })
  ];

  # $out for the library and $examples for the example programs (in examples):
  outputs = [ "out" "examples" ];

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [
    wayland libGL wayland-protocols libinput libxkbcommon pixman
    xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa
    libpng ffmpeg_4 freerdp
  ];

  mesonFlags = [
    "-Dlibcap=enabled" "-Dlogind=enabled" "-Dxwayland=enabled" "-Dx11-backend=enabled"
    "-Dxcb-icccm=enabled" "-Dxcb-errors=enabled"
  ];

  postPatch = ''
    # It happens from time to time that the version wasn't updated:
    sed -i "/^project(/,/^)/ s/\\bversion: '\([0-9]\.[0-9]\.[0-9]\)'/version: '\1-${version}'/" meson.build
  '';

  postInstall = ''
    # Copy the library to $examples
    mkdir -p $examples/lib
    cp -P libwlroots* $examples/lib/
  '';

  postFixup = ''
    # Install ALL example programs to $examples:
    # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
    # screenshot output-layout multi-pointer rotation tablet touch pointer
    # simple
    mkdir -p $examples/bin
    cd ./examples
    for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
      cp "$binary" "$examples/bin/wlroots-$binary"
    done
  '';

  meta = with stdenv.lib; {
    description = "A modular Wayland compositor library";
    inherit (src.meta) homepage;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
