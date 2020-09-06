{ stdenv, buildPythonPackage, fetchPypi, pytest, tox }:
buildPythonPackage rec {
  pname = "darglint";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1hf0z15mdd7f4f0746v5jya9zh365flb4ryh05ljwlg40gjgf4c5";
  };

  doCheck = false;
  checkInputs = [ pytest tox ];
  checkPhase = ''
    tox
  '';

  meta = with stdenv.lib; {
    description = "A utility for ensuring Google-style docstrings stay up to date with the source code";
    homepage = https://pypi.org/project/darglint;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

