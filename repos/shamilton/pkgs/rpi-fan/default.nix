{ lib
, stdenvNoCC
, substituteAll
, bc
, temp_min ? 40
, temp_max ? 60
, fan_min ? 0
, fan_max ? 255
}:

stdenvNoCC.mkDerivation rec {
  inherit temp_min temp_max fan_min fan_max;
  pname = "rpi-fan";
  version = "unstable";
  
  src = ./fan.sh;
  dontUnpack = true;

  postPatch = ''
    cp $src ./fan.sh
    substituteAll fan.sh rpi-fan
  '';

  installPhase = ''
    runHook preInstall
    install -Dm 755 rpi-fan "$out/bin/rpi-fan"
    runHook postInstall
  '';

  propagatedBuildInputs = [ bc ];

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
