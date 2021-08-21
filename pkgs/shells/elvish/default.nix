{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2021-08-19g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=-dev-${builtins.substring 0 9 src.rev} -X src.elv.sh/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "22ad09cc9355b870d218d38ba2101b27887c277e";
    sha256 = "1jji0p287glr03mxay19zp7kn3rhxga4a62va07zp00chnivljj2";
  };

  vendorSha256 = "0cmsijnvkz6p6kz2gymlxshjzgbdwp6agwpzlpzd4bvzp8d71mp6";
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

  passthru = {
    shellPath = "/bin/elvish";
  };
}
