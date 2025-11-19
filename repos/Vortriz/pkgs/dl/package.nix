{
    lib,
    python3,
    python3Packages,
    fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
    pname = "dl";
    version = "0-unstable-2025-11-19";
    pyproject = true;

    pythonRelaxDeps = true;

    src = fetchFromGitHub {
        owner = "Vortriz";
        repo = "dl";
        rev = "4782a5047cce228487692b4363020f71fab0c527";
        sha256 = "sha256-LJEiYh3wV501FoLtmo4s8+ER+BnCSEp1Q98xMVWSbLs=";
    };

    build-system = [ python3Packages.uv-build ];

    dependencies = with python3Packages; [
        aria2p
        click
    ];

    meta = with lib; {
        description = "A simple command-line tool to download files using `aria2c` and automatically sort them into categorized directories.";
        homepage = "https://github.com/Vortriz/dl";
        license = licenses.gpl3Only;
        mainProgram = "dl";
    };
}
