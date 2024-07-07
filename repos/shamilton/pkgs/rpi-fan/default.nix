{ lib
, stdenvNoCC
, callPackage
, substituteAll
, bc
, dtc
, coreutils
, libraspberrypi
, temp_max ? 70
}:
let
  rpi-poe-dts = ./rpi-poe.dts;
  overlays_dir = callPackage({ dtc }: stdenvNoCC.mkDerivation {
    name = "overlays-with-rpi-poe-dtbo";
    nativeBuildInputs = [ dtc ];
    buildCommand = ''
      mkdir -p "$out"
      mkdir temp
      pushd temp
      cp ${rpi-poe-dts} ./rpi-poe.dts
      dtc -I dts ./rpi-poe.dts -O dtb -@ -o "$out/rpi-poe.dtbo"
      popd
    '';
  }) {};
in
stdenvNoCC.mkDerivation rec {
  inherit temp_max overlays_dir;
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
    description = "Little bash script to that controls the rpi fans";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
