{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = "manual-tests";
    description = "TQDM progress bar helpers for logging and other headless application";
    homepage = "https://pypi.org/project/tqdm-loggable/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
