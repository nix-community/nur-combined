{ lib, buildPythonPackage, fetchPypi }:
buildPythonPackage rec {
  pname = "cognitive_complexity";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0r1bmy8jlyhgicav6l58mzpslbdw885yqdy96czwfh0shzr6nica";
  };

  # Tests are broken: pytest can't find tests properly
  doCheck = false;

  meta = with lib; {
    description = "Library to calculate Python functions cognitive complexity via code";
    homepage = https://github.com/Melevir/cognitive_complexity;
    license = licenses.mit;
  };
}
