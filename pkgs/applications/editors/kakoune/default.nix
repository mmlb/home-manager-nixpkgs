{ lib, stdenv, fetchFromGitHub, ncurses, asciidoc, docbook_xsl, libxslt, pkg-config }:

with lib;

stdenv.mkDerivation rec {
  pname = "kakoune-unwrapped";
  version = "unstable-2021-03-20g${builtins.substring 0 9 src.rev}";
  src = fetchFromGitHub {
    owner = "mawww";
    repo = "kakoune";
    rev = "739ed7ef67041be117f34acead7184dd78fe9410";
    sha256 = "0y37vkrns9mbxwm8vrdbcm316l64xdv3z1gj306r12xvi9ny39wj";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses asciidoc docbook_xsl libxslt ];
  makeFlags = [ "debug=no" ];

  postPatch = ''
    export PREFIX=$out
    cd src
    sed -ie 's#--no-xmllint#--no-xmllint --xsltproc-opts="--nonet"#g' Makefile
  '';

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
    maintainers = with maintainers; [ vrthra ];
    platforms = platforms.unix;
  };
}
