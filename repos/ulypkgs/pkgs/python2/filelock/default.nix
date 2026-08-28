{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "filelock";
  version = "3.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-nN0pxBGrGWz0w1odpoT3udpyNpbLNW76Rb9esf8xPuM=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  meta = with lib; {
    homepage = "https://github.com/benediktschmitt/py-filelock";
    description = "A platform independent file lock for Python";
    license = licenses.unlicense;
    maintainers = with maintainers; [ henkkalkwater ];
  };
})
