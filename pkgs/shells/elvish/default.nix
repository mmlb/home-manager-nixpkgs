{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2022-06-07g${builtins.substring 0 9 src.rev}";

  subPackages = "cmd/elvish";

  CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.VCSOverride=01011970-${
      builtins.substring 0 12 src.rev
    }"
    "-X src.elv.sh/pkg/buildinfo.BuildVariant=nixpkgs"
  ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "cb8628bcb6b32ad94191a66a52a59d64badf9990";
    sha256 = "0k30xbjxfr6xi6k9mpyprbg5m7yjla5x3ds86b1y5j0i23bz54mb";
  };

  vendorSha256 = "sha256-j0eo0l7lZLDMGpWtYCeLyJaTX5bBSCQpJxmMzmMrgI0=";

  strictDeps = true;
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out${passthru.shellPath} -c "
      fn expect {|key expected|
        var actual = \$buildinfo[\$key]
        if (not-eq \$actual \$expected) {
          fail '\$buildinfo['\$key']: expected '(to-string \$expected)', got '(to-string \$actual)
        }
      }

      expect version 0.19.0-dev.0.01011970-${
        builtins.substring 0 12 src.rev
      }+nixpkgs
    "

    runHook postInstallCheck
  '';

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

  passthru.shellPath = "/bin/elvish";
}
