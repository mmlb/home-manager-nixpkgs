{ stdenv, fetchFromGitHub, cmake, gettext, msgpack, libtermkey, libiconv
, libuv, lua, ncurses, pkgconfig
, unibilium, xsel, gperf
, libvterm-neovim
, glibcLocales ? null, procps ? null

# now defaults to false because some tests can be flaky (clipboard etc)
, doCheck ? false
}:

with stdenv.lib;

let
  neovimLuaEnv = lua.withPackages(ps:
    (with ps; [ mpack lpeg luabitop ]
    ++ optionals doCheck [
        nvim-client luv coxpcall busted luafilesystem penlight inspect
      ]
    ));
in
  stdenv.mkDerivation rec {
    name = "neovim-unwrapped-${version}";
    version = "20190213g" + (builtins.substring 0 8 "${src.rev}");

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "969cc55993919530b2a96e30f02fe71711cab28a";
      sha256 = "0hkywnf7q629c9nlk27f68619j5i08iwrxfyvgpdv1jypl8bj6i7";
    };

    patches = [
      # introduce a system-wide rplugin.vim in addition to the user one
      # necessary so that nix can handle `UpdateRemotePlugins` for the plugins
      # it installs. See https://github.com/neovim/neovim/issues/9413.
      ./system_rplugin_manifest.patch
    ];

    enableParallelBuilding = true;

    buildInputs = [
      libtermkey
      libuv
      msgpack
      ncurses
      libvterm-neovim
      unibilium
      gperf
      neovimLuaEnv
    ] ++ optional stdenv.isDarwin libiconv
      ++ optionals doCheck [ glibcLocales procps ]
    ;

    inherit doCheck;

    # to be exhaustive, one could run
    # make oldtests too
    checkPhase = ''
      make functionaltest
    '';

    nativeBuildInputs = [
      cmake
      gettext
      pkgconfig
    ];


    # nvim --version output retains compilation flags and references to build tools
    postPatch = ''
      substituteInPlace src/nvim/version.c --replace NVIM_VERSION_CFLAGS "";
    '';
    # check that the above patching actually works
    disallowedReferences = [ stdenv.cc ];

    cmakeFlags = [
      "-DLUA_PRG=${neovimLuaEnv}/bin/lua"
      "-DGPERF_PRG=${gperf}/bin/gperf"
    ]
    ++ optional doCheck "-DBUSTED_PRG=${neovimLuaEnv}/bin/busted"
    ;

    # triggers on buffer overflow bug while running tests
    hardeningDisable = [ "fortify" ];

    preConfigure = stdenv.lib.optionalString stdenv.isDarwin ''
      substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    '';

    postInstall = stdenv.lib.optionalString stdenv.isLinux ''
      sed -i -e "s|'xsel|'${xsel}/bin/xsel|g" $out/share/nvim/runtime/autoload/provider/clipboard.vim
    '';

    # export PATH=$PWD/build/bin:${PATH}
    shellHook=''
      export VIMRUNTIME=$PWD/runtime
    '';

    meta = {
      description = "Vim text editor fork focused on extensibility and agility";
      longDescription = ''
        Neovim is a project that seeks to aggressively refactor Vim in order to:
        - Simplify maintenance and encourage contributions
        - Split the work between multiple developers
        - Enable the implementation of new/modern user interfaces without any
          modifications to the core source
        - Improve extensibility with a new plugin architecture
      '';
      homepage    = https://www.neovim.io;
      # "Contributions committed before b17d96 by authors who did not sign the
      # Contributor License Agreement (CLA) remain under the Vim license.
      # Contributions committed after b17d96 are licensed under Apache 2.0 unless
      # those contributions were copied from Vim (identified in the commit logs
      # by the vim-patch token). See LICENSE for details."
      license = with licenses; [ asl20 vim ];
      maintainers = with maintainers; [ manveru garbas rvolosatovs ];
      platforms   = platforms.unix;
      # `lua: bad light userdata pointer`
      # https://nix-cache.s3.amazonaws.com/log/9ahcb52905d9d417zsskjpc331iailpq-neovim-unwrapped-0.2.2.drv
      broken = stdenv.isAarch64;
    };
  }
