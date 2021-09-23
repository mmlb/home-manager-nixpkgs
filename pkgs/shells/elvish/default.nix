{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-09-21g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${
      builtins.substring 0 9 src.rev
    }"
    "-X src.elv.sh/pkg/buildinfo.Reproducible=true"
  ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "1d62b0d68bce2820057853958bae4186b9ba5419";
    sha256 = "1w47aaqsyg076vv2xn27d12g0kr58kz56b2g4r0qgkw12gv123vb";
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
  };

  passthru = { shellPath = "/bin/elvish"; };
}
