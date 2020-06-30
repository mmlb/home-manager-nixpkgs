{ stdenv, fetchFromGitHub, meson, ninja, pkg-config, wayland
, libGL, wayland-protocols, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, mesa
, libpng, ffmpeg
}:

stdenv.mkDerivation rec {
  pname = "wlroots";
  version = "unstable-2020-06-30g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = pname;
    rev = "c611a8f7e7df7a10b434500760dfbcfdf2817413";
    sha256 = "0nl4z20w49xahg7bq1vmhmk5wq9d6gc1kdmhyl9yb9n1w2jng8gn";
  };

  # $out for the library and $examples for the example programs (in examples):
  outputs = [ "out" "examples" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ meson ninja pkg-config wayland ];

  buildInputs = [
    libGL wayland-protocols libinput libxkbcommon pixman
    xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa
    libpng ffmpeg
  ];

  postPatch = ''
    # Add the revision to the version
    sed -i "/^project(/,/^)/ s/\\bversion: '\([0-9]\+\.[0-9]\+\.[0-9]\+\)'/version: '\1-${version}'/" meson.build
  '';

  mesonFlags = [ "-Dlogind-provider=systemd" ];

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
    longDescription = ''
      Pluggable, composable, unopinionated modules for building a Wayland
      compositor; or about 50,000 lines of code you were going to write anyway.
    '';
    inherit (src.meta) homepage;
    changelog = "https://github.com/swaywm/wlroots/releases/tag/${version}";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
