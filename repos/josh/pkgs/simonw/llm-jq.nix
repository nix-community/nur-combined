{
  lib,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonPackage rec {
  __structuredAttrs = true;

  pname = "llm-jq";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-jq";
    tag = version;
    hash = "sha256-Mf/tbB9+UdmSRpulqv5Wagr8wjDcRrNs2741DNQZhO4=";
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.llm
  ];

  dependencies = [ ];

  pythonImportsCheck = [
    "llm_jq"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Write and execute jq programs with the help of LLM";
    homepage = "https://github.com/simonw/llm-jq";
    changelog = "https://github.com/simonw/llm-jq/releases/tag/${version}";
    license = lib.licenses.asl20;
  };
}
