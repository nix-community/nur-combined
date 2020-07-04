{ lib
, buildPythonPackage
, fetchPypi
, backports_unittest-mock
, monotonic
, pysendfile
}:

buildPythonPackage rec {
  pname = "pyfastcopy";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    pname = "pyfastcopy";
    extension = "tar.gz";
    sha256 = "ed4620f1087a8949888973e315d3d59fbe9b8cc4ca5df553d76d2f21d2748999";
  };

  nativeBuildInputs = [
    backports_unittest-mock
    monotonic
    pysendfile
  ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/desbma/pyfastcopy";
    description = "Speed up Python's shutil.copyfile by using sendfile system call";
    license = lib.licenses.psfl;
    # maintainers = with lib.maintainers; [ zeratax ];
  };
}