{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2022-04-09g${builtins.substring 0 9 src.rev}";

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
    rev = "faebab700196277eb879b60b35f30e5e656ee44b";
    sha256 = "0hl194jqqif1lnsc1h949g6j854kdnlfbjlrk3kchwm6jx3xlyi2";
  };

  vendorSha256 = "sha256-j0eo0l7lZLDMGpWtYCeLyJaTX5bBSCQpJxmMzmMrgI0=";

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
