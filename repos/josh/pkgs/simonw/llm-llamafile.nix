{
  lib,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonPackage rec {
  __structuredAttrs = true;

  pname = "llm-llamafile";
  version = "0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-llamafile";
    tag = version;
    hash = "sha256-LF1LhKgi7Pm1cRpFweyawDqXiDwfexa37HtpgOs6JoQ=";
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.llm
  ];

  dependencies = [ ];

  pythonImportsCheck = [
    "llm_llamafile"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Access llamafile localhost models via LLM";
    homepage = "https://github.com/simonw/llm-llamafile";
    changelog = "https://github.com/simonw/llm-llamafile/releases/tag/${version}";
    license = lib.licenses.asl20;
  };
}
