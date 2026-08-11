{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  sqlcipher,
}:

buildPythonPackage rec {
  pname = "pysqlcipher3";
  version = "unstable-2025-10-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rigglemania";
    repo = "pysqlcipher3";
    # https://github.com/rigglemania/pysqlcipher3/pull/38
    rev = "ef340612bc49751adc14ec27b3a2950dad2ebaf3";
    hash = "sha256-f6KUNzyIHZ53kXZbQOxv/kpRSRunbyuJgemsQArG/2M=";
  };

  build-system = [
    setuptools
    wheel
  ];

  buildInputs = [
    sqlcipher
  ];

  pythonImportsCheck = [
    "pysqlcipher3"
  ];

  meta = {
    description = "Python 3 bindings for SQLCipher";
    homepage = "https://github.com/rigglemania/pysqlcipher3";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ ];
  };
}
