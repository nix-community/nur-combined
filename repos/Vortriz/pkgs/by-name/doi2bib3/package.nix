{
    lib,
    python3Packages,
    fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
    pname = "doi2bib3";
    version = "0.9.1";
    pyproject = true;

    src = fetchFromGitHub {
        owner = "archisman-panigrahi";
        repo = "doi2bib3";
        tag = "v0.9.1";
        hash = "sha256-bDHd92YkWcOc7uU0JdrHRCt9bYi3syE2SQ2trrn3WjA=";
    };

    build-system = with python3Packages; [
        setuptools
        wheel
    ];

    dependencies = with python3Packages; [
        bibtexparser
        requests
    ];

    pythonImportsCheck = [
        "doi2bib3"
    ];

    meta = {
        description = "DOI/arXiv → BibTeX command line utility";
        homepage = "https://github.com/archisman-panigrahi/doi2bib3";
        license = lib.licenses.gpl3Only;
        mainProgram = "doi2bib3";
    };
}
