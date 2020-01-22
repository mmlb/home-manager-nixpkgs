{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "elvish";
  version = "unstable-2020-01-18g${builtins.substring 0 9 src.rev}";

  buildFlagsArray = ''
    -ldflags=-X github.com/elves/elvish/buildinfo.Version=${version}
  '';

  src = fetchFromGitHub {
    owner = "elves";
    repo = pname;
    rev = "41985123d3c3103619a6afc849ae58c4d95e1099";
    sha256 = "0h5d1087xjakiz4v2kgs9k9bz6aj2jii0nzdnxlawv4a96j9fx4r";
  };
  modSha256 = "00njpsmhga3fl56qg3qpjksfxfbsk435w750qybsby2i51mkn09x";

  meta = with stdenv.lib; {
    description = "A friendly and expressive command shell";
    longDescription = ''
      Elvish is a friendly interactive shell and an expressive programming
      language. It runs on Linux, BSDs, macOS and Windows. Despite its pre-1.0
      status, it is already suitable for most daily interactive use.
    '';
    homepage = https://elv.sh/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ vrthra AndersonTorres ];
    platforms = with platforms; linux ++ darwin;
  };

  passthru = {
    shellPath = "/bin/elvish";
  };
}
