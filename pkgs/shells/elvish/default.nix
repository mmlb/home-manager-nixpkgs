{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-08-30g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [
    "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${
      builtins.substring 0 9 src.rev
    } -X src.elv.sh/pkg/buildinfo.Reproducible=true"
  ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "ff0d1f9ca50692ada6df393d01df787b3d3249f1";
    sha256 = "1ahzdx4jyp9pm29p8zgy8b4haaaghhsahf2zq4vnk2c7g2jawfqd";
  };

  vendorSha256 = "1cqdd2mvq6xnpwkjg5jkqwwcd64q257brmjmay1kgbmm2dbihpgk";
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

  passthru = { shellPath = "/bin/elvish"; };
}
