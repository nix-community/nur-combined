{ lib
, buildPythonPackage
, fetchPypi
, notebook
, matplotlib
, lesscpy
}:

buildPythonPackage rec {
  pname = "jupyterthemes";
  version = "0.20.0";

  propagatedBuildInputs = [ notebook matplotlib lesscpy ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "07mldarwi9wi5m4v4x9s1n9m6grab307yxgip6csn4mjhh6br3ia";
  };

  meta = with lib; {
    description = "Custom Jupyter Notebook Themes";
    homepage = "https://github.com/dunovank/jupyter-themes";
    license = licenses.mit;
  };
}
