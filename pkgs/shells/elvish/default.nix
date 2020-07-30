{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-02-06g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${builtins.substring 0 9 src.rev} -X src.elv.sh/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "75e7b862dc8dd8ffe75dbfa196998034aa33077a";
    sha256 = "0935s4jdqgmg3a3qhhk9ibs66wqam53m7ky14fkd61vj9ra33z0c";
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
