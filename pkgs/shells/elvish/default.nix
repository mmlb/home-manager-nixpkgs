{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-12-12g${builtins.substring 0 9 src.rev}";

  excludedPackages =
    [ "./website" "./website/cmd/elvdoc" "./cmd/nodaemon/elvish" ];

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
    rev = "089752147a68935b0c610654b3cee667ec22ea9d";
    sha256 = "sha256-su3qin6NO9mfV/b7EELQd4/f3uHYr9Ajwiybw6AjIrU=";
  };

  vendorSha256 = "sha256-WmW8rYHL6smDQfmearv2xyQTxMyk3ys0REqTOQIBp4A=";
  CGO_ENABLED = 0;

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

      expect version ${version}
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
