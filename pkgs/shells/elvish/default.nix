{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-03-22g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${builtins.substring 0 9 src.rev} -X src.elv.sh/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "4e89c374d94561077f8d4173dca59f1997e917a6";
    sha256 = "1g6x93av4hpxqbr1c8i9lqkba30y9rmzqczncn273k937j1hyyxx";
  };

  vendorSha256 = "1nn5sj04dkx457s5pjlhpnmxpgdy3zzq5l7vgjkynpmikfwvlvxp";
  CGO_ENABLED = 0;

  doCheck = false;

  meta = with lib; {
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
