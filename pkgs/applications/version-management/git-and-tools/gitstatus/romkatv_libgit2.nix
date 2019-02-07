{ fetchFromGitHub, libgit2, ...}:

libgit2.overrideAttrs (oldAttrs: {
  cmakeFlags = oldAttrs.cmakeFlags ++ [
    "-DZERO_NSEC=ON"
    "-DTHREADSAFE=ON"
    "-DUSE_BUNDLED_ZLIB=ON"
    "-DREGEX_BACKEND=builtin"
    "-DUSE_HTTP_PARSER=builtin"  # overwritten from libgit2
    "-DUSE_SSH=OFF"
    "-DUSE_HTTPS=OFF"
    "-DBUILD_CLAR=OFF"
    "-DUSE_GSSAPI=OFF"
    "-DUSE_NTLMCLIENT=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
  ];
  src = fetchFromGitHub {
    owner = "romkatv";
    repo = "libgit2";
    rev = "d6c37a38587c9af2a9e63449fc8bf951dca0e854";
    sha256 = "0y5srmvjg7w3658gyxnm2gcgpp6iba72kgqykzs6s7hfk819rg9p";
  };
})
