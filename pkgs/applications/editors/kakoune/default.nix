{ lib, stdenv, fetchFromGitHub, ncurses, asciidoc, docbook_xsl, libxslt
, pkg-config }:

with lib;

stdenv.mkDerivation rec {
  pname = "kakoune-unwrapped";
  version = "unstable-2022-07-19g${builtins.substring 0 9 src.rev}";
  src = fetchFromGitHub {
    owner = "mawww";
    repo = "kakoune";
    rev = "559af669c77a3b3b6de0376f177ebbba5ebd0328";
    sha256 = "172k3cb9fdk5bb8wypxgm73xlni45xmwhzlsfl3k2fi2133x98q4";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses asciidoc docbook_xsl libxslt ];
  makeFlags = [ "debug=no" "PREFIX=${placeholder "out"}" ];

  preConfigure = ''
    export version="v${version}"
  '';

  enableParallelBuilding = true;

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/kak -ui json -e "kill 0"
  '';

  postInstall = ''
    # make share/kak/autoload a directory, so we can use symlinkJoin with plugins
    cd "$out/share/kak"
    autoload_target=$(readlink autoload)
    rm autoload
    mkdir autoload
    ln -s --relative "$autoload_target" autoload
  '';

  meta = {
    homepage = "http://kakoune.org/";
    description = "A vim inspired text editor";
    license = licenses.publicDomain;
    mainProgram = "kak";
    maintainers = with maintainers; [ vrthra ];
    platforms = platforms.unix;
  };
}
