{
  fetchFromGitHub,
  lib,
  nix-update-script,

  # python packages
  buildPythonPackage,
  setuptools,
  requests,
  typing-extensions,
}:

buildPythonPackage (final: {
  pname = "kagiapi";
  version = "0-unstable-2025-04-18";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagiapi";
    rev = "53176fbd98cf880105b901dea9a1a8e623f25e1b";
    hash = "sha256-Z0JFwQlG672lehogam8GyIcELCaoxBD0w4tkNBMjxQ8=";
  };

  build-system = [
    setuptools
  ];

  pythonRelaxDeps = true;
  dependencies = [
    requests
    typing-extensions
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=main"
      final.pname
    ];
  };

  meta = {
    description = "Kagi Search API";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/kagisearch/kagiapi";
    changelog = "https://github.com/kagisearch/kagiapi/commits/main";
  };
})
