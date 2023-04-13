{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "Distance";
  # renovate: datasource=pypi depName=Distance
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YIB1hPW2AD9cUhqnPzn1H2Md475czMWh1nFm/L8NRVE=";
  };

  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "Utilities for comparing sequences";
    homepage = "https://github.com/doukremt/distance";
    license = licenses.gpl2;
  };
}
