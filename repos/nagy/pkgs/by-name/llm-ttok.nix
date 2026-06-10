{
  lib,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication rec {

  pname = "llm-ttok";
  version = "0.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "ttok";
    tag = version;
    hash = "sha256-I6EPE6GDAiDM+FbxYzRW4Pml0wDA2wNP1y3pD3dg7Gg=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = [
    python3.pkgs.click
    python3.pkgs.tiktoken
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Count and truncate text based on tokens";
    homepage = "https://github.com/simonw/ttok";
    changelog = "https://github.com/simonw/ttok/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ttok";
  };
}
