{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2022-01-30g${builtins.substring 0 9 src.rev}";

  subPackages = "cmd/elvish";

  CGO_ENABLED = 0;
  ldflags =
    [ "-s" "-w" "-X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${version}" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "2c8bae8496bc0cd5ccc128646926923ad2deee7e";
    sha256 = "1ypvpqin073g4isbgwk4rdfyp7cplay3w9sf0p98dk8s2hhxvfk5";
  };

  vendorSha256 = "sha256-WmW8rYHL6smDQfmearv2xyQTxMyk3ys0REqTOQIBp4A=";

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

      expect version 0.18.0-dev-${version}
      expect reproducible \$false
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
