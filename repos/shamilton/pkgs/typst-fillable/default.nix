{
  python3Packages,
  fetchFromGitHub,
  lib,
  # nix-gitignore,
}:
python3Packages.buildPythonPackage {
  pname = "typst-fillable";
  version = "2026-07-09";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "typst-fillable";
    rev = "2021e52d3a25c446eec0136f6e8b33469c9d1bf6";
    hash = "sha256-oEHlrIr9GQ5kyV2MWxOANNaJDao66uZN6UEYmu1VZEk=";
  };
  # src = nix-gitignore.gitignoreSource [] ~/GIT/typst-fillable;

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    typst
    reportlab
    pypdf
    pydantic
  ];

  pythonImportsCheck = [ "typst_fillable" ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Create fillable PDF forms from Typst templates with interactive text fields, checkboxes, and radio buttons";
    homepage = "https://github.com/carpe-diem/typst-fillable";
    license = lib.licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
  };
}
