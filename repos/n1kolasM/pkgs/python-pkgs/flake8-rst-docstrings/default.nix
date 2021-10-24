{ lib, buildPythonPackage, fetchPypi
, flake8, restructuredtext_lint }:
buildPythonPackage rec {
  pname = "flake8-rst-docstrings";
  version = "0.0.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "173gr8j8iazycdpnhjkp3g5ca0jsgviimdzy7mnb508ph0kq7lq1";
  };

  propagatedBuildInputs = [ flake8 restructuredtext_lint ];
  
  meta = with lib; {
    description = "Python docstring reStructuredText (RST) validator";
    homepage = https://pypi.org/project/flake8-rst-docstrings;
    license = licenses.mit;
  };
}

