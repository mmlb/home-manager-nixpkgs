{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2022-01-04g${builtins.substring 0 9 src.rev}";

  subPackages = "cmd/elvish";

  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${version}"
    "-X src.elv.sh/pkg/buildinfo.Reproducible=true"
  ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "4fc4ca3cc16e6986ada8f6cbda949aed6535ed35";
    sha256 = "168ra63fa1rzjiq5whwpjxk7vbaqikdnmygm0jm9srpf23vc7xhs";
  };

  vendorSha256 = "sha256-WmW8rYHL6smDQfmearv2xyQTxMyk3ys0REqTOQIBp4A=";
  CGO_ENABLED = 0;

  doCheck = true;

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

      expect version 0.18.0-dev-${version}
      expect reproducible \$true
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
