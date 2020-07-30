{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-06-13g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${builtins.substring 0 9 src.rev} -X src.elv.sh/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "3204e700ac4583c6892da9fb8c4e2d87c9b0cf7b";
    sha256 = "08lvnhyphjg97zi8nkp2d9hf6ihig7dj0yzdfgw99xfziqlpy84i";
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
