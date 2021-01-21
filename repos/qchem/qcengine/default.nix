{ buildPythonPackage, lib, fetchPypi
, pyyaml
, qcelemental
, pydantic
, py-cpuinfo
, psutil
, cacert
, pytestrunner
, pytest
, pytestcov
}:
  buildPythonPackage rec {
    pname = "qcengine";
    version = "0.17.0";

    checkInputs = [
      pytestrunner
      pytestcov
      pytest
    ];

    propagatedBuildInputs = [
      cacert
      pyyaml
      qcelemental
      pydantic
      py-cpuinfo
      psutil
    ];

    src = fetchPypi  {
      inherit pname version;
      sha256 = "19a2ca5a341514f8f6c491e7570ecd4e98cf31290bd34d47a475722100cc971d";
    };

    doCheck = true;

    meta = with lib; {
      description = "Quantum chemistry program executor and IO standardizer (QCSchema) for quantum chemistry.";
      license = licenses.bsd3;
      homepage = "http://docs.qcarchive.molssi.org/projects/qcelemental/en/latest/";
      platforms = platforms.unix;
    };
  }
