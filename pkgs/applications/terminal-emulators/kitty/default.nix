{ lib, stdenv, fetchFromGitHub, harfbuzz, installShellFiles, libicns, ncurses
, pkg-config, python3

# linux specific
, dbus, fontconfig, lcms2, libcanberra, libGL, libstartup_notification
, libunistring, libX11, libXcursor, libXext, libXi, libXinerama, libxkbcommon
, libXrandr, wayland, wayland-protocols, xsel,

# darwin specific
Cocoa, CoreGraphics, Foundation, imagemagick, IOKit, Kernel, OpenGL, libpng
, zlib, }:

python3.pkgs.buildPythonApplication rec {
  pname = "kitty";
  version = "unstable-2021-08-20g${builtins.substring 0 9 src.rev}";
  format = "other";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty";
    rev = "cd7b4fcd8e0cda6fa2d5ca18a308630bffc7bba9";
    sha256 = "0vpc17j8nxkq3w4kk05bfx4slv2k7mc29938pds6298fl59h676r";
  };

  buildInputs = [ harfbuzz lcms2 ncurses ] ++ lib.optionals stdenv.isDarwin [
    Cocoa
    CoreGraphics
    Foundation
    IOKit
    Kernel
    libpng
    OpenGL
    python3
    zlib
  ] ++ lib.optionals stdenv.isLinux [
    dbus
    fontconfig
    libcanberra
    libunistring
    libX11
    libXcursor
    libXext
    libXi
    libXinerama
    libxkbcommon
    libXrandr
    wayland
    wayland-protocols
  ];

  nativeBuildInputs = [ installShellFiles ncurses pkg-config ]
    ++ (with python3.pkgs; [
      furo
      sphinx
      sphinx-copybutton
      sphinxext-opengraph
      sphinx-inline-tabs
    ]) ++ lib.optionals stdenv.isDarwin [
      imagemagick
      libicns # For the png2icns tool.
    ];

  propagatedBuildInputs = lib.optional stdenv.isLinux libGL;

  outputs = [ "out" "terminfo" ];

  # Causes build failure due to warning
  hardeningDisable = lib.optional stdenv.cc.isClang "strictoverflow";

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    ${if stdenv.isDarwin then ''
      ${python3.interpreter} setup.py kitty.app \
      --update-check-interval=0 \
      --disable-link-time-optimization
      make man
    '' else ''
      ${python3.interpreter} setup.py linux-package \
      --update-check-interval=0 \
      --egl-library='${lib.getLib libGL}/lib/libEGL.so.1' \
      --startup-notification-library='${libstartup_notification}/lib/libstartup-notification-1.so' \
      --canberra-library='${libcanberra}/lib/libcanberra.so'
    ''}
    runHook postBuild
  '';

  checkInputs = [ python3.pkgs.pillow ];

  checkPhase = let
    buildBinPath = if stdenv.isDarwin then
      "kitty.app/Contents/MacOS"
    else
      "linux-package/bin";
  in ''
    env PATH="${buildBinPath}:$PATH" ${python3.interpreter} test.py
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    ${if stdenv.isDarwin then ''
      mkdir "$out/bin"
      ln -s ../Applications/kitty.app/Contents/MacOS/kitty "$out/bin/kitty"
      mkdir "$out/Applications"
      cp -r kitty.app "$out/Applications/kitty.app"

      installManPage 'docs/_build/man/kitty.1'
    '' else ''
      cp -r linux-package/{bin,share,lib} $out
    ''}
    wrapProgram "$out/bin/kitty" --prefix PATH : "$out/bin:${
      lib.makeBinPath [ imagemagick xsel ncurses.dev ]
    }"

    installShellCompletion --cmd kitty \
      --bash <("$out/bin/kitty" + complete setup bash) \
      --fish <("$out/bin/kitty" + complete setup fish) \
      --zsh  <("$out/bin/kitty" + complete setup zsh)

    runHook postInstall
  '';

  postInstall = ''
    terminfo_src=${
      if stdenv.isDarwin then
        ''"$out/Applications/kitty.app/Contents/Resources/terminfo"''
      else
        "$out/share/terminfo"
    }

    mkdir -p $terminfo/share
    mv "$terminfo_src" $terminfo/share/terminfo

    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  meta = with lib; {
    homepage = "https://github.com/kovidgoyal/kitty";
    description =
      "A modern, hackable, featureful, OpenGL based terminal emulator";
    license = licenses.gpl3Only;
    changelog = "https://sw.kovidgoyal.net/kitty/changelog.html";
    platforms = platforms.darwin ++ platforms.linux;
    maintainers = with maintainers; [ tex rvolosatovs Luflosi ];
  };
}
