{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "dtmfdial";
  version = "unstable-2023-09-16";

  # based on
  # http://www.gtlib.gatech.edu/pub/Linux/apps/sound/misc/dtmf-dial-0.2.tar.gz
  # http://www.ibiblio.org/pub/linux/apps/sound/misc/dtmf-dial-0.2.tar.gz

  src = fetchFromGitHub {
    owner = "TJNII";
    repo = "dtmfdial";
    rev = "b6d6f927b62a97a09d788ec4dfec1ed9b3fd75ac";
    hash = "sha256-IjrRgkhGqK4lPJZlaXzZQ1a7LmftxB6chPX+vCdlE+8=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -v dial $out/bin
    mkdir -p $out/share/doc/${pname}
    cp README.md $out/share/doc/${pname}
  '';

  meta = with lib; {
    description = "Generate DTMF dial tones";
    homepage = "https://github.com/TJNII/dtmfdial";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "dtmfdial";
    platforms = platforms.all;
  };
}
