{ lib, stdenv, fetchFromGitHub, fetchpatch, python3Packages, bashInteractive
, Cocoa, CoreGraphics, darwin, dbus, fish, fontconfig, Foundation, harfbuzz
, imagemagick, installShellFiles, IOKit, Kernel, lcms2, libcanberra, libGL
, libicns, libpng, librsync, libstartup_notification, libunistring, libX11
, libXcursor, libXext, libXi, libXinerama, libxkbcommon, libXrandr, ncurses
, OpenGL, pkg-config, python3, wayland, wayland-protocols, xsel, zlib, zsh }:

with python3Packages;
buildPythonApplication rec {
  pname = "kitty";
  version = "0.24.4";
  format = "other";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty";
    rev = "v${version}";
    sha256 = "sha256-c6XM/xeGZ68srf8xQJA1iYCUR3kXNceTMxsZAnbFmug=";
  };

  buildInputs = [ harfbuzz lcms2 librsync ncurses ]
    ++ lib.optionals stdenv.isDarwin [
      Cocoa
      CoreGraphics
      Foundation
      IOKit
      Kernel
      libpng
      OpenGL
      python3
      zlib
    ] ++ lib.optionals (stdenv.isDarwin
      && (builtins.hasAttr "UserNotifications" darwin.apple_sdk.frameworks))
    [ darwin.apple_sdk.frameworks.UserNotifications ]
    ++ lib.optionals stdenv.isLinux [
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

  nativeBuildInputs = [
    furo
    installShellFiles
    ncurses
    pkg-config
    sphinx
    sphinx-copybutton
    sphinxext-opengraph
    sphinx-inline-tabs
  ] ++ lib.optionals stdenv.isDarwin [
    imagemagick
    libicns # For the png2icns tool.
  ];

  propagatedBuildInputs = lib.optional stdenv.isLinux libGL;

  outputs = [ "out" "terminfo" "shell_integration" ];

  patches = [
    (fetchpatch {
      name = "fix-zsh-completion-test-1.patch";
      url =
        "https://github.com/kovidgoyal/kitty/commit/297592242c290a81ca4ba08802841f4c33a4de25.patch";
      sha256 = "sha256-/V6y/4AaJsZvx1KS5UFZ+0zyAoZuLgbgFORZ1dX/1qE=";
    })
    (fetchpatch {
      name = "fix-zsh-completion-test-2.patch";
      url =
        "https://github.com/kovidgoyal/kitty/commit/d8ed42ae8e014d9abf9550a65ae203468f8bfa43.patch";
      sha256 = "sha256-Azgzqf5atW999FVn9rSGKMyZLsI692dYXhJPx07GBO0=";
    })
  ];

  # Causes build failure due to warning
  hardeningDisable = lib.optional stdenv.cc.isClang "strictoverflow";

  dontConfigure = true;

  buildPhase = let
    commonOptions = ''
      --update-check-interval=0 \
      --shell-integration=enabled\ no-rc
    '';
  in ''
    runHook preBuild
    ${if stdenv.isDarwin then ''
      ${python.interpreter} setup.py kitty.app \
      --disable-link-time-optimization \
      ${commonOptions}
      make man
    '' else ''
      ${python.interpreter} setup.py linux-package \
      --egl-library='${lib.getLib libGL}/lib/libEGL.so.1' \
      --startup-notification-library='${libstartup_notification}/lib/libstartup-notification-1.so' \
      --canberra-library='${libcanberra}/lib/libcanberra.so' \
      ${commonOptions}
    ''}
    runHook postBuild
  '';

  checkInputs = [
    pillow

    # Shells needed for shell integration tests
    bashInteractive
    fish
    zsh
  ];

  checkPhase = let
    buildBinPath = if stdenv.isDarwin then
      "kitty.app/Contents/MacOS"
    else
      "linux-package/bin";
  in ''
    # Fontconfig error: Cannot load default config file: No such file: (null)
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf

    env PATH="${buildBinPath}:$PATH" ${python.interpreter} test.py
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
      --bash <("$out/bin/kitty" +complete setup bash) \
      --fish <("$out/bin/kitty" +complete setup fish2) \
      --zsh  <("$out/bin/kitty" +complete setup zsh)

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

    cp -r 'shell-integration' "$shell_integration"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/kovidgoyal/kitty";
    description =
      "A modern, hackable, featureful, OpenGL based terminal emulator";
    license = licenses.gpl3Only;
    changelog = "https://sw.kovidgoyal.net/kitty/changelog/";
    platforms = platforms.darwin ++ platforms.linux;
    maintainers = with maintainers; [ tex rvolosatovs Luflosi ];
  };
}
