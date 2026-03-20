{
    lib,
    python3Packages,
    fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
    pname = "doi2bib3";
    version = "0.7.0";
    pyproject = true;

    src = fetchFromGitHub {
        owner = "archisman-panigrahi";
        repo = "doi2bib3";
        tag = "v0.7.0";
        hash = "sha256-L+zTOkOfJImgGcz0X+BY6WMiKG97gWLzSoCh3BpEY0o=";
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
        maintainers = with lib.maintainers; [ ];
        mainProgram = "doi2bib3";
    };
}
