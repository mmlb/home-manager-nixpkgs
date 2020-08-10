{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2020-08-04g${builtins.substring 0 9 src.rev}";

  excludedPackages = [ "website" ];

  buildFlagsArray = [ "-ldflags=-s -w -X github.com/elves/elvish/pkg/buildinfo.Version==${version} -X github.com/elves/elvish/pkg/buildinfo.Reproducible=true" ];

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "3300c81c8bf5c6754c34414c1f315625e2c90a11";
    sha256 = "0mvxznaidd38mdhksb5da6j48faa9yis1a47ibf7ysy4vf0s8hh4";
  };

  vendorSha256 = "1129njnk78srni3snkl47x77g0pqqszm8a6hh9h23vprglasnarb";

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
