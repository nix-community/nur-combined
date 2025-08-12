{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  setuptools,
  pythonRelaxDepsHook,
  xdis,
  click,
  configobj,
  spark-parser
}:

buildPythonPackage rec {
  pname = "decompyle3";
  version = "3.9.2";

  src = fetchFromGitHub {
    owner = "rocky";
    repo = "python-decompile3";
    tag = version;
    hash = "sha256-F/Wb8Nua8EInp4Pb5puDSqipfDjHJahm7S+tbAKKWIQ=";
  };

  pyproject = true;
  build-system = [
    setuptools
  ];
  disabled = pythonOlder "3.7";

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  dependencies = [
    xdis
    click
    configobj
    spark-parser
  ];

  pythonRelaxDeps = [
    "spark-parser"
  ];

  pythonImportsCheck = [ "decompyle3" ];

  meta = {
    description = "Python decompiler for 3.7-3.8.";
    longDescription = "Python decompiler for 3.7-3.8. Stripped down from uncompyle6 so we can refactor and start to fix up some long-standing problems";
    homepage = "https://github.com/rocky/python-decompile3";
    changelog = "https://github.com/rocky/python-decompile3/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "decompyle3";
  };
}
