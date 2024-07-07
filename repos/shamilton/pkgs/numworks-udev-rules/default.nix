{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "numworks-udev-rules";
  version = "unstable-2020-08-31";

  udevRules = fetchurl {
    # let's pin the latest commit in the repo which touched the udev rules file
    url = "https://cdn.numworks.com/f2be8a48/50-numworks-calculator.rules";
    sha256 = "sha256-x4leQyuSdNsXwpZRZPUJWkJNZDRl2WhqC3PHizChe8w=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm 644 "${udevRules}" "$out/lib/udev/rules.d/50-numworks-calculator.rules"
  '';

  meta = with lib; {
    description = "Udev rules for Numworks calculators";
    homepage = "https://numworks.com";
    license = licenses.gpl3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
