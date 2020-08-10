{ stdenv, fetchFromGitHub, ncurses, asciidoc, docbook_xsl, libxslt, pkgconfig }:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "kakoune-unwrapped";
  version = "unstable-2020-08-04g${builtins.substring 0 9 src.rev}";
  src = fetchFromGitHub {
    repo = "kakoune";
    owner = "mawww";
    rev = "2c437cfa02ca568750182209ef6249c6975243a5";
    sha256 = "1cgkis8bywy5k8k6j4i3prikpmhh1p6zyklliyxbc89mj64kvx4s";
  };
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ ncurses asciidoc docbook_xsl libxslt ];
  makeFlags = [ "debug=no" ];
  enableParallelBuilding = true;

  postPatch = ''
    export PREFIX=$out
    cd src
    sed -ie 's#--no-xmllint#--no-xmllint --xsltproc-opts="--nonet"#g' Makefile
  '';

  preConfigure = ''
    export version="v${version}"
  '';

  doInstallCheckPhase = true;
  installCheckPhase = ''
    $out/bin/kak -ui json -E "kill 0"
  '';

  meta = {
    homepage = "http://kakoune.org/";
    description = "A vim inspired text editor";
    license = licenses.publicDomain;
    maintainers = with maintainers; [ vrthra ];
    platforms = platforms.unix;
  };
}
