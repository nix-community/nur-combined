{
    inputs,
    lib,
    python3Packages,
}:
python3Packages.buildPythonApplication {
    pname = "doi2bib3";
    version = inputs._meta.doi2bib3.version;
    pyproject = true;

    src = inputs.doi2bib3;

    build-system = with python3Packages; [
        setuptools
        wheel
    ];

    dependencies = with python3Packages; [
        bibtexparser
        requests
        pylatexenc
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
