{ lib, stdenv, fetchFromGitHub, zlib, protobuf, ncurses, pkgconfig
, makeWrapper, perlPackages, openssl, autoreconfHook, openssh, bash-completion
, libutempter ? null, withUtempter ? stdenv.isLinux }:

stdenv.mkDerivation rec {
  pname = "mosh";
  version = "unstable-2020-05-18g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "mobile-shell";
    repo = pname;
    rev = "03087e7a761df300c2d8cd6e072890f8e1059dfa";
    sha256 = "170m3q9sxw6nh8fvrf1l0hbx0rjjz5f5lzhd41143kd1rps3liw8";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ protobuf ncurses zlib makeWrapper openssl bash-completion ]
    ++ (with perlPackages; [ perl IOTty ])
    ++ lib.optional withUtempter libutempter;

  enableParallelBuilding = true;

  patches = [
    ./ssh_path.patch
    ./utempter_path.patch
    # Fix build with bash-completion 2.10
    ./bash_completion_datadir.patch
  ];
  postPatch = ''
    substituteInPlace scripts/mosh.pl \
        --subst-var-by ssh "${openssh}/bin/ssh"
  '';

  configureFlags = [ "--enable-completion" ] ++ lib.optional withUtempter "--with-utempter";

  postInstall = ''
      wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB
  '';

  CXXFLAGS = stdenv.lib.optionalString stdenv.cc.isClang "-std=c++11";

  meta = {
    homepage = "https://mosh.org/";
    description = "Mobile shell (ssh replacement)";
    longDescription = ''
      Remote terminal application that allows roaming, supports intermittent
      connectivity, and provides intelligent local echo and line editing of
      user keystrokes.

      Mosh is a replacement for SSH. It's more robust and responsive,
      especially over Wi-Fi, cellular, and long-distance links.
    '';
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = stdenv.lib.platforms.unix;
  };
}
