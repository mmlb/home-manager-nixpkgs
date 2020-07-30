{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-01-24g${builtins.substring 0 9 src.rev}";

  subPackages = [ "cmd/elvish" ];

  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.Version==${version}"
    "-X src.elv.sh/pkg/buildinfo.Reproducible=true"
  ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "1c2fa28ccef9f4687a0bf69a62463c40127607b7";
    sha256 = "1jksdpf86miz1dv3vrmvpvz4k1c2m23dway6a7b1cypg03c68a75";
  };

  vendorSha256 = "124m9680pl7wrh7ld7v39dfl86r6vih1pjk3bmbihy0fjgxnnq0b";

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
