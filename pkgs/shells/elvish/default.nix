{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-05-11g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${builtins.substring 0 9 src.rev} -X src.elv.sh/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "4717debfeca7f5e1da43828269514452565067b1";
    sha256 = "1nrxmja7rym20i2amhsf8xhpk8skssjff7s4qsfab3r6s50cnq8h";
  };

  vendorSha256 = "0cmsijnvkz6p6kz2gymlxshjzgbdwp6agwpzlpzd4bvzp8d71mp6";
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
