{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "numworks-udev-rules";
  version = "unstable-2020-08-31";

  udevRules = fetchurl {
    # let's pin the latest commit in the repo which touched the udev rules file
    url = "https://workshop.numworks.com/files/drivers/linux/50-numworks-calculator.rules";
    sha256 = "1k3vl4q8pivk1dm6inb56ij4shjs17sn8lcnq8bxnx4j5d1mx2f7";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm 644 "${udevRules}" "$out/lib/udev/rules.d/50-numworks-calculator.rules"
  '';

  meta = with stdenv.lib; {
    description = "Udev rules for Numworks calculators";
    homepage = "https://numworks.com";
    license = licenses.gpl3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
