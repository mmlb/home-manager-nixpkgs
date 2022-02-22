{ lib, stdenv, fetchFromGitHub, ncurses, asciidoc, docbook_xsl, libxslt
, pkg-config }:

with lib;

stdenv.mkDerivation rec {
  pname = "kakoune-unwrapped";
  version = "unstable-2022-02-21g${builtins.substring 0 9 src.rev}";
  src = fetchFromGitHub {
    owner = "mawww";
    repo = "kakoune";
    rev = "30c05e83f8cbd0e116b9f8652f1cd2ade95add80";
    sha256 = "0s4kifls2x0ily1cz9dg2c9miga7kyqva71b07bi2843n8kn4dvf";
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
