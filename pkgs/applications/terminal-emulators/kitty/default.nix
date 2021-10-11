{ lib, stdenv, fetchFromGitHub, harfbuzz, installShellFiles, lcms2, librsync
, libstartup_notification, ncurses, pkg-config, python3, xsel

# Linux Specific
, dbus, fontconfig, libcanberra, libGL, libunistring, libX11, libXcursor
, libXext, libXi, libXinerama, libxkbcommon, libXrandr, wayland
, wayland-protocols

# Darwin Specific
, Cocoa, CoreGraphics, darwin, Foundation, imagemagick, IOKit, Kernel, libicns
, libpng, OpenGL, zlib }:

python3.pkgs.buildPythonApplication rec {
  pname = "kitty";
  version = "unstable-2022-02-01g${builtins.substring 0 9 src.rev}";
  format = "other";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty";
    rev = "43ceaf0b7e85422d7d97502c2407e94337b5a50d";
    sha256 = "1bgg168849a32fbrf3dchbm2yi9zc11a749c7dia7cynvlk6gl72";
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

  outputs = [ "out" "terminfo" "shell_integration" ];

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
      ${python3.interpreter} setup.py kitty.app \
      --update-check-interval=0 \
      --disable-link-time-optimization
      make man
    '' else ''
      ${python3.interpreter} setup.py linux-package \
      --update-check-interval=0 \
      --egl-library='${lib.getLib libGL}/lib/libEGL.so.1' \
      --startup-notification-library='${libstartup_notification}/lib/libstartup-notification-1.so' \
      --canberra-library='${libcanberra}/lib/libcanberra.so' \
      ${commonOptions}
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
    # Fontconfig error: Cannot load default config file: No such file: (null)
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf

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
