{ lib
, stdenvNoCC
, callPackage
, substituteAll
, bc
, dtc
, coreutils
, libraspberrypi
, temp_min ? 40
, temp_max ? 60
, fan_min ? 0
, fan_max ? 255
}:
let
  rpi-poe-overlay-source = ./rpi-poe.dts;
  overlays_dir = callPackage({ dtc }: stdenvNoCC.mkDerivation {
    name = "overlays-with-rpi-poe-dtbo";
    nativeBuildInputs = [ dtc ];
    buildCommand = ''
      mkdir -p "$out"
      dtc -I dts ${rpi-poe-overlay-source} -O dtb -@ -o "$out/rpi-poe.dtbo"
    '';
  }) {};
in
stdenvNoCC.mkDerivation rec {
  inherit temp_min temp_max fan_min fan_max overlays_dir;
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

  propagatedBuildInputs = [ bc coreutils libraspberrypi ];

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
