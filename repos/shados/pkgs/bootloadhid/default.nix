{
  lib,
  stdenv,
  fetchurl,
  libusb-compat-0_1,
  libusb1,
}:
stdenv.mkDerivation rec {
  pname = "bootloadHID";
  version = "2012-12-08";

  src = fetchurl {
    url = "https://www.obdev.at/downloads/vusb/${pname}.${version}.tar.gz";
    sha256 = "0m471p14q1lg1ygpvw8qf2jykwp23vxfsrpn5pn2wflsc8w7wkhm";
  };

  sourceRoot = "${pname}.${version}/commandline";

  nativeBuildInputs = [
    libusb-compat-0_1
  ];

  buildInputs = [
    libusb1
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bootloadHID $out/bin/
  '';

  meta = with lib; {
    description = "Tool for flashing devices using bootloadHID firmware";
    homepage = "https://www.obdev.at/products/vusb/bootloadhid.html";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl2;
  };
}
