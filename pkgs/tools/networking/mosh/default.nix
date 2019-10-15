{ lib, stdenv, fetchFromGitHub, zlib, protobuf, ncurses, pkgconfig
, makeWrapper, perlPackages, openssl, autoreconfHook, openssh, bash-completion
, libutempter ? null, withUtempter ? stdenv.isLinux }:

stdenv.mkDerivation rec {
  name = "mosh-${version}";
  version = "unstable-2019-10-03g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "mobile-shell";
    repo = "mosh";
    rev = "0cc492dbae2f6aaef9a54dc2a8ba3222868b150f";
    sha256 = "0w7jxdsyxgnf5h09rm8mfgm5z1qc1sqwvgzvrwzb04yshxpsg0zd";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ protobuf ncurses zlib makeWrapper openssl bash-completion ]
    ++ (with perlPackages; [ perl IOTty ])
    ++ lib.optional withUtempter libutempter;

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
    homepage = https://mosh.org/;
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
