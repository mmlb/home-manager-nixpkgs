{ lib, stdenv, fetchFromGitHub, pkg-config, wrapGAppsHook, alsa-lib, gtk3, libpulseaudio }:

stdenv.mkDerivation rec {
  pname = "praat";
  version = "6.2.22";

  src = fetchFromGitHub {
    owner = "praat";
    repo = "praat";
    rev = "v${version}";
    sha256 = "sha256-RE4QDK5x9xG1RsAWB6dgviu3V1ay/+r0vyHCPCu/qCU=";
  };

  configurePhase = ''
    cp makefiles/makefile.defs.linux.pulse makefile.defs
  '';

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  installPhase = ''
    install -Dt $out/bin praat
  '';

  nativeBuildInputs = [ pkg-config wrapGAppsHook ];
  buildInputs = [ alsa-lib gtk3 libpulseaudio ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Doing phonetics by computer";
    homepage = "https://www.fon.hum.uva.nl/praat/";
    license = licenses.gpl2Plus; # Has some 3rd-party code in it though
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.linux;
  };
}
