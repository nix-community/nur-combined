{ lib, buildPythonPackage, fetchPypi, typing-extensions }:
buildPythonPackage rec {
  pname = "returns";
  version = "0.12.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a1m34zha5hd00hl5gc6njav8x2msprm64jbrbagir79gbnp2nxl";
  };

  propagatedBuildInputs = [ typing-extensions ];
  # Tests require poetry build from github distribution
  doCheck = false;

  meta = with lib; {
    description = "Make your functions return something meaningful, typed, and safe!";
    homepage = https://returns.readthedocs.io;
    license = licenses.bsd2;
    broken = true;
  };
}

