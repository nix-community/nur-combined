{ lib, python38Packages }:

with python38Packages;

buildPythonPackage rec {
  pname = "pyDes";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4quOIdK4PpDZDb/ctvuKwAALgTI4t+yu3gT4Q1w4kBI=";
  };

  meta = with lib; {
    description =
      "Pure python implementation of DES and TRIPLE DES encryption algorithm";
    homepage = "https://github.com/twhiteman/pyDes";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
