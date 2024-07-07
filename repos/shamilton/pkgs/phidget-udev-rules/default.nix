{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "phidget-udev-rules";
  version = "unstable-2023-01-12";

  udevRules = ./udev.rules;

  dontUnpack = true;

  installPhase = ''
    install -Dm 644 "${udevRules}" "$out/lib/udev/rules.d/50-phidget.rules"
  '';

  meta = with lib; {
    description = "Udev rules for Numworks calculators";
    homepage = "https://numworks.com";
    license = licenses.gpl3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
