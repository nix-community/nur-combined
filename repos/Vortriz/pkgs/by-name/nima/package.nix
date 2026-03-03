{
    lib,
    python3Packages,
    fetchFromGitHub,
}:
python3Packages.buildPythonPackage {
    pname = "nix-manipulator";
    version = "unstable-2026-03-03";

    src = fetchFromGitHub {
        owner = "Vortriz";
        repo = "nix-manipulator";
        rev = "e8fef717975c4ae349c831a0528dbcb95e916815";
        hash = "sha256-DQ6EWBRpdIo3Y5ld9JHf0HFLQX0XoWhyKRXICz+Vf4A=";
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
