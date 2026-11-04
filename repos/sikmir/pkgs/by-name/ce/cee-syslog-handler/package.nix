{
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "cee-syslog-handler";
  version = "0.6.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "cee_syslog_handler";
    inherit (finalAttrs) version;
    hash = "sha256-ur62PXCi2N66c0//WtNyP+1tBToBYhoZk3+QAxWBPgs=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "cee_syslog_handler" ];

  meta = {
    description = "Python Syslog Logging Handler with CEE Support";
    homepage = "https://github.com/blue-yonder/cee_syslog_handler";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
