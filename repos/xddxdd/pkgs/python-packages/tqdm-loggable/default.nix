{
  sources,
  lib,
  buildPythonPackage,
  # Dependencies
  poetry-core,
  tqdm,
}:
buildPythonPackage {
  inherit (sources.tqdm-loggable) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    poetry-core
    tqdm
  ];

  pythonImportsCheck = [ "tqdm_loggable" ];

  meta = {
    mainProgram = "manual-tests";
    description = "TQDM progress bar helpers for logging and other headless application";
    homepage = "https://pypi.org/project/tqdm-loggable/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
}
