{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pytest,
  unrar,
}:

buildPythonPackage rec {
  pname = "python-unrar";
  version = "0.4";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "unrar";
    hash = "sha256-skRHpbkwJL5gDvglVmi6I6MPRRF2V3tpFVnqE1n30WQ=";
  };

  build-system = [
    setuptools
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    runHook preCheck

    export UNRAR_LIB_PATH=${unrar}/lib/libunrar.so
    pytest

    runHook postCheck
  '';

  meta = with lib; {
    homepage = "http://github.com/matiasb/python-unrar";
    description = "A ctypes wrapper for UnRAR library, plus a rarfile module on top of it";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
