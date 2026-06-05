{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
  unstableGitUpdater,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "kagiapi";
  version = "0-unstable-2025-04-18";

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagiapi";
    rev = "53176fbd98cf880105b901dea9a1a8e623f25e1b";
    hash = "sha256-Z0JFwQlG672lehogam8GyIcELCaoxBD0w4tkNBMjxQ8=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
  ];

  propagatedBuildInputs = [
    python3.pkgs.requests
    python3.pkgs.typing-extensions
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "kagiapi"
  ];

  doCheck = true;
  strictDeps = true;

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    homepage = "https://github.com/kagisearch/kagiapi";
    description = "A Python package for Kagi Search API";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
