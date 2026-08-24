{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  python-dotenv,
}:
buildPythonPackage (finalAttrs: {
  pname = "rootutils";
  version = "1.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ashleve";
    repo = "rootutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MY6kYB3IhMvyLCVVC2kdpMvbwKY4XyTfq9cXxbqbnPI=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    python-dotenv
  ];

  pythonImportsCheck = [ "rootutils" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/ashleve/rootutils/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple python package to solve all your problems with pythonpath, work dir, file paths, module imports and environment variables";
    homepage = "https://pypi.org/project/rootutils/";
    license = with lib.licenses; [ mit ];
  };
})
