{
  lib
, buildPythonPackage
, fetchPypi

, colorama
, pyocd-pemicro
, libusb-package
, pyusb
, prettytable25
, capstone
, pyyaml
, pyelftools
, cmsis-pack-manager
, typing-extensions
, natsort
, pylink-square012
, intelhex
, intervaltree
}:
buildPythonPackage rec {
  version = "0.33.1";
  pname = "pyocd";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-kwBix4mwcNddTQeId6G/1URoHhBrBDIIAnMYFufUbNk=";
  };

  propagatedBuildInputs = [
    colorama
    pyocd-pemicro
    libusb-package
    prettytable25
    capstone
    pyyaml
    pyelftools
    cmsis-pack-manager
    typing-extensions
    natsort
    pylink-square012
    intelhex
    intervaltree
    pyusb
  ];
}