{ lib, stdenv, fetchurl, cmake, makeWrapper
, llvm, libclang
, flex
, zlib
, perlPackages
, util-linux
}:

stdenv.mkDerivation rec {
  pname = "creduce";
  version = "2.10.0";

  src = fetchurl {
    url = "https://embed.cs.utah.edu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "2xwPEjln8k1iCwQM69UwAb89zwPkAPeFVqL/LhH+oGM=";
  };

  nativeBuildInputs = [ cmake makeWrapper llvm.dev ];
  buildInputs = [
    # Ensure stdenv's CC is on PATH before clang-unwrapped
    stdenv.cc
    # Actual deps:
    llvm libclang
    flex zlib
  ] ++ (with perlPackages; [ perl ExporterLite FileWhich GetoptTabular RegexpCommon TermReadKey ]);

  # On Linux, c-reduce's preferred way to reason about
  # the cpu architecture/topology is to use 'lscpu',
  # so let's make sure it knows where to find it:
  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace creduce/creduce_utils.pm --replace \
      lscpu ${util-linux}/bin/lscpu
  '';

  postInstall = ''
    wrapProgram $out/bin/creduce --prefix PERL5LIB : "$PERL5LIB"
  '';

  meta = with lib; {
    description = "A C program reducer";
    homepage = "https://embed.cs.utah.edu/creduce";
    # Officially, the license is: https://github.com/csmith-project/creduce/blob/master/COPYING
    license = licenses.ncsa;
    longDescription = ''
      C-Reduce is a tool that takes a large C or C++ program that has a
      property of interest (such as triggering a compiler bug) and
      automatically produces a much smaller C/C++ program that has the same
      property.  It is intended for use by people who discover and report
      bugs in compilers and other tools that process C/C++ code.
    '';
    maintainers = [ maintainers.dtzWill ];
    platforms = platforms.all;
  };
}
