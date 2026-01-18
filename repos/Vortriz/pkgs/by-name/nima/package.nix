{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage {
  pname = "nix-manipulator";
  version = "unstable-2025-12-25";

  src = fetchFromGitHub {
    owner = "Vortriz";
    repo = "nix-manipulator";
    rev = "98a3fc6811e906ea7ac6ad9c2744fcaee4596a18";
    hash = "sha256-qJTtXux7bzJaJgnQpvSBMaJnNAyzqzVcLGvtOC8iv3I=";
  };

  pyproject = true;
  pythonRelaxDeps = true;

  build-system = [ python3Packages.uv-build ];

  dependencies = with python3Packages; [
    pydantic
    pygments
    tree-sitter
    tree-sitter-grammars.tree-sitter-nix
  ];

  doCheck = true;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  checkPhase = ''
        pytest -v -m "not nixpkgs"
    '';

  disabledTests = [
    "test_some_nixpkgs_packages"
  ];

  pythonImportsCheck = [ "nima" ];

  meta = {
    description = "Parse, manipulate, and reconstruct Nix source code with high-level abstractions";
    homepage = "https://github.com/Vortriz/nix-manipulator";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "nima";
  };
}