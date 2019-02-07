{ callPackage, stdenv, fetchFromGitHub, ...}:

stdenv.mkDerivation rec {
  pname = "gitstatus";
  version = "unstable-2020-06-22g${builtins.substring 0 9 src.rev}";

  src = fetchFromGitHub {
    owner = "romkatv";
    repo = pname;
    rev = "0f5402c8686a593cd21b95ade28a154dd51749bb";
    sha256 = "033c6dc92nvm9dwixpfgrdskq5ddkyq7zbykr419wacihymi5f9i";
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
