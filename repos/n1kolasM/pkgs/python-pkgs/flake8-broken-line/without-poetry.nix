{ stdenv, buildPythonPackage, fetchPypi, flake8, setuptools, importlib-metadata, pythonOlder }:
buildPythonPackage rec {
  pname = "flake8-broken-line";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0drmmxdnw855wq99zf1zq2y3bgfbar0j00wy18yla7li94vqldrh";
  };

  propagatedBuildInputs = [
    flake8
    setuptools
  ] ++ stdenv.lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];
  # Tests require poetry build from github distribution
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Flake8 plugin to forbid backslashes for line breaks";
    homepage = https://pypi.org/project/flake8-broken-line;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

