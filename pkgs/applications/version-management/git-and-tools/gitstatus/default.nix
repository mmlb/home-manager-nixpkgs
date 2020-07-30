{ callPackage, stdenv, fetchFromGitHub, ...}:

stdenv.mkDerivation rec {
  pname = "gitstatus";
  version = "unstable-2020-08-15g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "romkatv";
    repo = pname;
    rev = "3f874d9c5933d184b9b06472dcf25e8debb326a8";
    sha256 = "0zan1sa8c24hpqwj66y9srd4n15f4nk64fc5jrd4smgfgn22wph8";
  };

  buildInputs = [ (callPackage ./romkatv_libgit2.nix {}) ];
  patchPhase = ''
    sed -i "1i GITSTATUS_DAEMON=$out/bin/gitstatusd" gitstatus.plugin.zsh
  '';
  installPhase = ''
    install -Dm755 usrbin/gitstatusd $out/bin/gitstatusd
    install -Dm444 gitstatus.plugin.zsh $out
  '';

  meta = with stdenv.lib; {
    description = "10x faster implementation of `git status` command";
    homepage = "https://github.com/romkatv/gitstatus";
    license = [ licenses.gpl3 ];
    maintainers = with maintainers; [ mmlb hexa ];
  };
}
