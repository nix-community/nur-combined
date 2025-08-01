{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
  pygments,
}:

buildPythonPackage rec {
  pname = "pyclang";
  version = "0.5.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-stcQaXHkSsXgcz19TUWF27e8O/eWlrvaTKKFk0JeHVQ=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  passthru.optional-dependencies = {
    html = [
      pygments
    ];
  };

  pythonImportsCheck = [ "pyclang" ];

  meta = {
    description = "Python clang-tidy runner";
    homepage = "https://pypi.org/project/pyclang/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pyclang";
  };
}
