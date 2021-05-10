{ buildPythonPackage, lib, fetchPypi, fetchFromGitHub
# Other dependencies
, cacert
# Python dependencies
, numpy
, pydantic
, pint
, networkx
, pytestrunner
, pytestcov
, pytest
}:
buildPythonPackage rec {
  pname = "qcelemental";
  version = "0.19.0";

  checkInputs = [
    pytestrunner
    pytestcov
    pytest
  ];

  propagatedBuildInputs = [
    numpy
    pydantic
    pint
    networkx
    cacert
  ];

  src = fetchPypi  {
    inherit pname version;
    sha256 = "1ljxwhiz1689qijjqzmzydn8q963xx7zxizjnjq0vqg5py9pkyc5";
  };

  doCheck = true;

  meta = with lib; {
    description = "Periodic table, physical constants, and molecule parsing for quantum chemistry.";
    license = licenses.bsd3;
    homepage = "http://docs.qcarchive.molssi.org/projects/qcelemental/en/latest/";
    platforms = platforms.unix;
  };
}
