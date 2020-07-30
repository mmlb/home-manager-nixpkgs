{ lib, stdenv, fetchFromGitHub, ncurses, asciidoc, docbook_xsl, libxslt, pkg-config }:

with lib;

stdenv.mkDerivation rec {
  pname = "kakoune-unwrapped";
  version = "unstable-2021-03-31g${builtins.substring 0 9 src.rev}";
  src = fetchFromGitHub {
    owner = "mawww";
    repo = "kakoune";
    rev = "212242cc602d386fe1b7c1ce10c55ad0430c4960";
    sha256 = "0lq7ajyad40r8my3ys6dhgyjl88mdnbjsq844by0x5xm2fi5790s";
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
