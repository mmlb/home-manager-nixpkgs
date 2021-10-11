{ lib, buildGoModule, fetchFromGitHub, runCommand }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2022-03-20g${builtins.substring 0 9 src.rev}";

  subPackages = "cmd/elvish";

  CGO_ENABLED = 0;
  ldflags =
    [ "-s" "-w" "-X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${version}" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "957c8a752145f8c91bc153723e3589e45b678d70";
    sha256 = "sha256-zUmPGNN5EjzALp1s6j+lilrOUR/kGcZJKeCkGWf04DQ=";
  };

  vendorSha256 = "sha256-iuklI7XEQUgZ2ObYRROxyiccZ1JkajK5OJA7hIcpRZQ=";

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

      expect version 0.19.0-dev-${version}
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
