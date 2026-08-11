{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pyjsparser";
  version = "2.7.1";
  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-vmDaa3eMxaUpamnY59YU8fhw+vlOGxtqxZHyrV1ylXk=";
  };
  meta = with lib; {
    homepage = "https://github.com/PiotrDabkowski/pyjsparser";
    description = "Fast javascript parser (based on esprima.js)";
    license = licenses.mit;
  };
}
