{
  lib,
  pins,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "usb-resetter";
  version = "1.3.0";

  src = pins.usb-resetter.outPath;

  pyproject = true;
  build-system = [ setuptools ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/netinvent/usb_resetter";
    license = licenses.bsd3;
    maintainer = with maintainers; [ arobyn ];
    description = "A small tool to reset USB controllers, hubs, or devices";
  };
}
