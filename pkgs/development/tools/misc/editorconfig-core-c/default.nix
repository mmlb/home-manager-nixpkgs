{ lib, stdenv, fetchFromGitHub, cmake, pcre, doxygen }:

stdenv.mkDerivation rec {
  pname = "editorconfig-core-c";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "editorconfig";
    repo = "editorconfig-core-c";
    rev = "v${version}";
    sha256 = "sha256-pFsbyqIt7okfaiOwlYN8EXm1SFlCUnsHVbOgyIZZlys=";
    fetchSubmodules = true;
  };

  buildInputs = [ pcre ];
  nativeBuildInputs = [ cmake doxygen ];

  # Multiple doxygen can not generate man pages in the same base directory in
  # parallel: https://bugzilla.gnome.org/show_bug.cgi?id=791153
  enableParallelBuilding = false;

  meta = with lib; {
    homepage = "https://editorconfig.org/";
    description = "EditorConfig core library written in C";
    longDescription = ''
      EditorConfig makes it easy to maintain the correct coding style when
      switching between different text editors and between different
      projects. The EditorConfig project maintains a file format and plugins
      for various text editors which allow this file format to be read and used
      by those editors. For information on the file format and supported text
      editors, see the EditorConfig website.
    '';
    downloadPage = "https://github.com/editorconfig/editorconfig-core-c";
    license = with licenses; [ bsd2 bsd3 ];
    maintainers = with maintainers; [ dochang ];
    platforms = platforms.unix;
    mainProgram = "editorconfig";
  };
}
