{
    lib,
    python3,
    python3Packages,
    fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication {
    pname = "dl";
    version = "unstable-2025-12-19";

    src = fetchFromGitHub {
        owner = "Vortriz";
        repo = "dl";
        rev = "13c9002d5bb08a6935027fd45a4489ec2bccf952";
        hash = "sha256-eNz0qhg5+QkBcIUeGEWfwrjA9u43PoDXgzj97AOSPTg=";
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
