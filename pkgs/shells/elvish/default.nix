{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2020-06-28g${builtins.substring 0 9 src.rev}";

  goPackagePath = "github.com/elves/elvish";
  excludedPackages = [ "website" ];
  buildFlagsArray = ''
    -ldflags=
      -X ${goPackagePath}/buildinfo.Version=${version}
  '';

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "587486399189b4b89dab4eca0a20d4d124eb74b1";
    sha256 = "0r3zfxsmjfwspmvycdpcd7z7a9ldrbjs7zs5pr1v4na7w23f2jdr";
  };

  vendorSha256 = "1f971n17h9bc0qcgs9ipiaw0x9807mz761fqm605br4ch1kp0897";

  meta = with stdenv.lib; {
    description = "A friendly and expressive command shell";
    longDescription = ''
      Elvish is a friendly interactive shell and an expressive programming
      language. It runs on Linux, BSDs, macOS and Windows. Despite its pre-1.0
      status, it is already suitable for most daily interactive use.
    '';
    homepage = "https://elv.sh/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ vrthra AndersonTorres ];
    platforms = with platforms; linux ++ darwin;
  };

  passthru = {
    shellPath = "/bin/elvish";
  };
}
