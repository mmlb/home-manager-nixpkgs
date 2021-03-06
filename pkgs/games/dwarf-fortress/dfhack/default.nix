{ stdenv
, buildEnv
, lib
, fetchFromGitHub
, cmake
, writeScriptBin
, perl
, XMLLibXML
, XMLLibXSLT
, zlib
, ruby
, enableStoneSense ? false
, allegro5
, libGLU
, libGL
, enableTWBT ? true
, twbt
, SDL
, dfVersion
}:

with lib;

let
  dfhack-releases = {
    "0.43.05" = {
      dfHackRelease = "0.43.05-r3.1";
      sha256 = "1ds366i0qcfbn62w9qv98lsqcrm38npzgvcr35hf6ihqa6nc6xrl";
      xmlRev = "860a9041a75305609643d465123a4b598140dd7f";
      prerelease = false;
    };
    "0.44.05" = {
      dfHackRelease = "0.44.05-r2";
      sha256 = "1cwifdhi48a976xc472nf6q2k0ibwqffil5a4llcymcxdbgxdcc9";
      xmlRev = "2794f8a6d7405d4858bac486a0bb17b94740c142";
      prerelease = false;
    };
    "0.44.09" = {
      dfHackRelease = "0.44.09-r1";
      sha256 = "1nkfaa43pisbyik5inj5q2hja2vza5lwidg5z02jyh136jm64hwk";
      xmlRev = "3c0bf63674d5430deadaf7befaec42f0ec1e8bc5";
      prerelease = false;
    };
    "0.44.10" = {
      dfHackRelease = "0.44.10-r2";
      sha256 = "19bxsghxzw3bilhr8sm4axz7p7z8lrvbdsd1vdjf5zbg04rs866i";
      xmlRev = "321bd48b10c4c3f694cc801a7dee6be392c09b7b";
      prerelease = false;
    };
    "0.44.11" = {
      dfHackRelease = "0.44.11-beta2.1";
      sha256 = "1jgwcqg9m1ybv3szgnklp6zfpiw5mswla464dlj2gfi5v82zqbv2";
      xmlRev = "f27ebae6aa8fb12c46217adec5a812cd49a905c8";
      prerelease = true;
    };
    "0.44.12" = {
      dfHackRelease = "0.44.12-r1";
      sha256 = "0j03lq6j6w378z6cvm7jspxc7hhrqm8jaszlq0mzfvap0k13fgyy";
      xmlRev = "23500e4e9bd1885365d0a2ef1746c321c1dd5094";
      prerelease = false;
    };
    "0.47.02" = {
      dfHackRelease = "0.47.02-alpha0";
      sha256 = "19lgykgqm0si9vd9hx4zw8b5m9188gg8r1a6h25np2m2ziqwbjj9";
      xmlRev = "23500e4e9bd1885365d0a2ef1746c321c1dd509a";
      prerelease = true;
    };
    "0.47.04" = {
      dfHackRelease = "0.47.04-r2";
      sha256 = "18ppn1dqaxi6ahjzsvb9kw70rvca106a1hibhzc4rxmraypnqb89";
      xmlRev = "036b662a1bbc96b4911f3cbe74dfa1243b6459bc";
      prerelease = false;
    };
    "0.47.05" = {
      dfHackRelease = "0.47.05-r1";
      sha256 = "sha256-B0iv7fpIcnaO8sx9wPqI7/WuyLK15p8UYlYIcF5F5bw=";
      xmlRev = "11c379ffd31255f2a1415d98106114a46245e1c3";
      prerelease = false;
    };

  };

  release =
    if hasAttr dfVersion dfhack-releases
    then getAttr dfVersion dfhack-releases
    else throw "[DFHack] Unsupported Dwarf Fortress version: ${dfVersion}";

  version = release.dfHackRelease;

  # revision of library/xml submodule
  xmlRev = release.xmlRev;

  arch =
    if stdenv.hostPlatform.system == "x86_64-linux" then "64"
    else if stdenv.hostPlatform.system == "i686-linux" then "32"
    else throw "Unsupported architecture";

  fakegit = writeScriptBin "git" ''
    #! ${stdenv.shell}
    if [ "$*" = "describe --tags --long" ]; then
      echo "${version}-unknown"
    elif [ "$*" = "describe --tags --abbrev=8 --long" ]; then
      echo "${version}-unknown"
    elif [ "$*" = "describe --tags --abbrev=8 --exact-match" ]; then
      echo "${version}"
    elif [ "$*" = "rev-parse HEAD" ]; then
      if [ "$(dirname "$(pwd)")" = "xml" ]; then
        echo "${xmlRev}"
      else
        echo "refs/tags/${version}"
      fi
    elif [ "$*" = "rev-parse HEAD:library/xml" ]; then
      echo "${xmlRev}"
    else
      exit 1
    fi
  '';

  dfhack = stdenv.mkDerivation {
    pname = "dfhack-base";
    inherit version;

    # Beware of submodules
    src = fetchFromGitHub {
      owner = "DFHack";
      repo = "dfhack";
      rev = release.dfHackRelease;
      sha256 = release.sha256;
      fetchSubmodules = true;
    };

    patches = [ ./fix-stonesense.patch ];

    # gcc 11 fix
    NIX_CFLAGS_COMPILE = "-fpermissive";

    # As of
    # https://github.com/DFHack/dfhack/commit/56e43a0dde023c5a4595a22b29d800153b31e3c4,
    # dfhack gets its goodies from the directory above the Dwarf_Fortress
    # executable, which leads to stock Dwarf Fortress and not the built
    # environment where all the dfhack resources are symlinked to (typically
    # ~/.local/share/df_linux). This causes errors like `tweak is not a
    # recognized command` to be reported and dfhack to lose some of its
    # functionality.
    postPatch = ''
      sed -i 's@cached_path = path_string.*@cached_path = getenv("DF_DIR");@' library/Process-linux.cpp
    '';

    nativeBuildInputs = [ cmake perl XMLLibXML XMLLibXSLT fakegit ];
    # We don't use system libraries because dfhack needs old C++ ABI.
    buildInputs = [ zlib SDL ]
      ++ lib.optionals enableStoneSense [ allegro5 libGLU libGL ];

    preConfigure = ''
      # Trick build system into believing we have .git
      mkdir -p .git/modules/library/xml
      touch .git/index .git/modules/library/xml/index
    '';

    cmakeFlags = [ "-DDFHACK_BUILD_ARCH=${arch}" "-DDOWNLOAD_RUBY=OFF" ]
      ++ lib.optionals enableStoneSense [ "-DBUILD_STONESENSE=ON" "-DSTONESENSE_INTERNAL_SO=OFF" ];

    # dfhack expects an unversioned libruby.so to be present in the hack
    # subdirectory for ruby plugins to function.
    postInstall = ''
      ln -s ${ruby}/lib/libruby-*.so $out/hack/libruby.so
    '';

  };
in

buildEnv {
  name = "dfhack-${version}";

  passthru = { inherit version dfVersion; };

  paths = [ dfhack ] ++ lib.optionals enableTWBT [ twbt.lib ];

  meta = with lib; {
    description = "Memory hacking library for Dwarf Fortress and a set of tools that use it";
    homepage = "https://github.com/DFHack/dfhack/";
    license = licenses.zlib;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ robbinch a1russell abbradar numinit ];
  };
}
