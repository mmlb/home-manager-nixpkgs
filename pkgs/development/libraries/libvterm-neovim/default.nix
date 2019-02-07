{ stdenv
, fetchFromGitHub
, perl
, libtool
}:

stdenv.mkDerivation rec {
  pname = "libvterm-neovim";
  version = "unstable-2020-01-06g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "neovim";
    repo = "libvterm";
    rev = "65dbda3ed214f036ee799d18b2e693a833a0e591";
    sha256 = "0r6yimzbkgrsi9aaxwvxahai2lzgjd1ysblr6m6by5w459853q3n";
  };

  buildInputs = [ perl ];
  nativeBuildInputs = [ libtool ];

  makeFlags = [ "PREFIX=$(out)" ]
    ++ stdenv.lib.optional stdenv.isDarwin "LIBTOOL=${libtool}/bin/libtool";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "VT220/xterm/ECMA-48 terminal emulator library";
    homepage = "http://www.leonerd.org.uk/code/libvterm/";
    license = licenses.mit;
    maintainers = with maintainers; [ rvolosatovs ];
    platforms = platforms.unix;
  };
}
