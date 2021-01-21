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
  version = "0.17.0";

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
    sha256 = "0xsxmj1l6l72ga06a1gy2kf7lqdgnx8hcgqw0ikvzgs0xj2w4421";
  };

  doCheck = true;

  meta = with lib; {
    description = "Periodic table, physical constants, and molecule parsing for quantum chemistry.";
    license = licenses.bsd3;
    homepage = "http://docs.qcarchive.molssi.org/projects/qcelemental/en/latest/";
    platforms = platforms.unix;
  };
}
