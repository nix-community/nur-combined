{ lib
, buildPythonPackage
, fetchPypi
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "RPi.GPIO";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "7424bc6c205466764f30f666c18187a0824077daf20b295c42f08aea2cb87d3f";
  };

  # Tests require custom circuit hooked up
  doCheck = false;
  # pythonImportsCheck = [ "RPi.GPIO" ];

  meta = with lib; {
    description = "A module to control Raspberry Pi GPIO channels";
    homepage = "http://sourceforge.net/p/raspberry-gpio-python/wiki/Home/";
    license = licenses.mit;
    platforms = [ "aarch64-linux" "armv7l-linux" "armv6l-linux" ];
  };
}
