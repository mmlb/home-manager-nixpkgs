{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2020-08-31g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X github.com/elves/elvish/pkg/buildinfo.Version==${version} -X github.com/elves/elvish/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "8988d6e5f0b4e3971edcee02c8a1300d9176dded";
    sha256 = "147r0v6jndpavs5y8njzz9hwvvsy286jfjy8lm8m33v8pqr6mxhx";
  };

  vendorSha256 = "0kpr5b4zqaa41l4bp1dmk854j2zgyq272b53z1njbm6abns3rqzh";

  doCheck = false;

  meta = with stdenv.lib; {
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
