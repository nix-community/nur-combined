{
    lib,
    mkZoteroAddon,
    fetchFromGitHub,
}:
mkZoteroAddon {
    pname = "Better BibTeX for Zotero";
    version = "7.0.68";

    src = fetchFromGitHub {
        owner = "retorquere";
        repo = "zotero-better-bibtex";
        tag = "v7.0.68";
        sha256 = "sha256-Nr6tSqeMqvmMl52crlPTegyquVbT1Y6nnve+muvEKT8=";
    };

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
