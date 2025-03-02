{
  lib,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonPackage rec {
  __structuredAttrs = true;

  pname = "llm-ttok";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "ttok";
    tag = version;
    hash = "sha256-I6EPE6GDAiDM+FbxYzRW4Pml0wDA2wNP1y3pD3dg7Gg=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.click
    python3Packages.tiktoken
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Count and truncate text based on tokens";
    homepage = "https://github.com/simonw/ttok";
    changelog = "https://github.com/simonw/ttok/releases/tag/${version}";
    license = lib.licenses.asl20;
    mainProgram = "ttok";
  };
}
