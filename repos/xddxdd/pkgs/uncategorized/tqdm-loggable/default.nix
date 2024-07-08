{
  sources,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  inherit (sources.tqdm-loggable) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    python3Packages.poetry-core
    python3Packages.tqdm
  ];

  pythonImportsCheck = [ "tqdm_loggable" ];

  meta = with lib; {
    mainProgram = "manual-tests";
    description = "TQDM progress bar helpers for logging and other headless application";
    homepage = "https://pypi.org/project/tqdm-loggable/";
    license = licenses.mit;
    maintainers = with maintainers; [ xddxdd ];
  };
}
