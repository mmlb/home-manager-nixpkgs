{ lib, stdenv, fetchFromGitHub, cmake, makeWrapper, itk-unstable, vtk_8, Cocoa }:

stdenv.mkDerivation rec {
  pname    = "ANTs";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner  = "ANTsX";
    repo   = "ANTs";
    rev    = "v${version}";
    sha256 = "sha256-sRZwRRqqU0xiu4K6xlLQV4xzVNnzMlnRsk+TPiv0wD0=";
  };

  nativeBuildInputs = [ cmake makeWrapper ];
  buildInputs = [ itk-unstable vtk_8 ] ++ lib.optionals stdenv.isDarwin [ Cocoa ];

  cmakeFlags = [ "-DANTS_SUPERBUILD=FALSE" "-DUSE_VTK=TRUE" ];

  postInstall = ''
    for file in $out/bin/*; do
      wrapProgram $file --set ANTSPATH "$out/bin"
    done
  '';

  meta = with lib; {
    homepage = "https://github.com/ANTsX/ANTs";
    description = "Advanced normalization toolkit for medical image registration and other processing";
    maintainers = with maintainers; [ bcdarwin ];
    platforms = platforms.unix;
    license = licenses.bsd3;
  };
}
