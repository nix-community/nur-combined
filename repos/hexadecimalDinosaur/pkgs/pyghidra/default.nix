{
  lib,
  buildPythonPackage,
  pythonOlder,
  ghidra,
  setuptools,
  jpype1,
  pytestCheckHook,
  pytest-datadir,
  openjdk21
}:

buildPythonPackage {
  pname = "pyghidra";
  version = ghidra.version;

  src = ghidra.src;

  sourceRoot = "${ghidra.src.name}/Ghidra/Features/PyGhidra/src/main/py";

  pyproject = true;
  build-system = [
    setuptools
  ];
  disabled = pythonOlder "3.9";

  dependencies = [
    jpype1
  ];

  preCheck = ''
    export GHIDRA_INSTALL_DIR="${ghidra.out}/lib/ghidra/"
  '';

  nativeCheckInputs = [
    # pytestCheckHook
    # pytest-datadir
    # openjdk21
  ];

  pythonImportsCheck = [ "pyghidra" ];

  meta = {
    description = "";
    homepage = "https://github.com/NationalSecurityAgency/ghidra/blob/master/Ghidra/Features/PyGhidra/src/main/py/README.md";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "pylingual";
  };
}
