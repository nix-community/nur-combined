{
    lib,
    python3,
    python3Packages,
    fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication {
    pname = "dl";
    version = "unstable-2026-03-19";

    src = fetchFromGitHub {
        owner = "Vortriz";
        repo = "dl";
        rev = "4b14f7192939ef17afe31ea649dfd9184bbf3fcb";
        hash = "sha256-8EeIMXcK3dRY4+RKXJXENI7hpCzTXFZPstwYV1CZ/ZM=";
    };

    pyproject = true;
    pythonRelaxDeps = true;

    build-system = [ python3Packages.uv-build ];

    dependencies = with python3Packages; [
        aria2p
        click
    ];

    meta = {
        description = "A simple command-line tool to download files using `aria2c` and automatically sort them into categorized directories.";
        homepage = "https://github.com/Vortriz/dl";
        license = lib.licenses.gpl3Only;
        mainProgram = "dl";
    };
}
