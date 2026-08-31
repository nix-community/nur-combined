{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  unstableGitUpdater,
  poetry-core,
  tqdm,
}:
buildPythonPackage (finalAttrs: {
  pname = "tqdm-loggable";
  version = "0-unstable-2026-03-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tradingstrategy-ai";
    repo = "tqdm-loggable";
    rev = "5083a123a4df17b6cb3cf3a80c0206c39eb5ec0b";
    hash = "sha256-NmokphM0trQmIm3Ke436gRMctAvV38hbo5MLjbcgLDs=";
  };
  propagatedBuildInputs = [
    poetry-core
    tqdm
  ];

  pythonImportsCheck = [ "tqdm_loggable" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/tradingstrategy-ai/tqdm-loggable";
    hardcodeZeroVersion = true;
  };
  meta = {
    mainProgram = "manual-tests";
    description = "TQDM progress bar helpers for logging and other headless application";
    homepage = "https://pypi.org/project/tqdm-loggable/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
