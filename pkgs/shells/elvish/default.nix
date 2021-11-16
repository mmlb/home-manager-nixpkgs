{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-11-14g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "./website" "./website/cmd/elvdoc" "./cmd/nodaemon/elvish" ];

  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${
      builtins.substring 0 9 src.rev
    }"
    "-X src.elv.sh/pkg/buildinfo.Reproducible=true"
  ];

  patchPhase = ''
  rm -rf website
  rm -rf cmd/nodaemon
  '';
  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "c59e01abfcd94f0e33b437ed778db1fe33eae167";
    sha256 = "1fgz957wc8yrk47262cb2q9qg7dj83mpc01lrdmdfg2yb69f09bi";
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
