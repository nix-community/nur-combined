{
    lib,
    python3Packages,
    fetchFromGitHub,
}:
python3Packages.buildPythonApplication {
    pname = "dunefetch";
    version = "0-unstable-2025-08-12";

    src = fetchFromGitHub {
        owner = "datavorous";
        repo = "dunefetch";
        rev = "7adfd33406a556b7d096f11dc446570c81b17675";
        fetchSubmodules = false;
        sha256 = "sha256-x6VlBa6qgwKyg8JxTCl6Y9rSzFk/8gaj2lanTZvl6XM=";
    };

    pyproject = true;

    build-system = with python3Packages; [
        setuptools
        wheel
    ];

    dependencies = with python3Packages; [
        psutil
    ];

    pythonImportsCheck = [
        "dunefetch"
    ];

    meta = {
        description = "Neofetch + falling sand engine for your terminal";
        homepage = "https://github.com/datavorous/dunefetch";
        license = lib.licenses.mit;
        mainProgram = "dunefetch";
    };
}
