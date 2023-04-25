{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "iterators";
  version = "0.0.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-T2pbOcPHJO3VxyMaWJ1GOtUDV83DVJSjxxcweVt461A=";
  };

  meta = with lib; {
    description = "Provides a wrapper class TimeoutIterator to add timeout feature to normal iterators";
    homepage = "https://github.com/leangaurav/pypi_iterator";
    license = licenses.mit;
    maintainers = [];
  };
}
