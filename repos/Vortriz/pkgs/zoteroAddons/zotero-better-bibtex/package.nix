{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "Better BibTeX for Zotero";
    version = "9.0.19";

    src = fetchurl {
        url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${version}/zotero-better-bibtex-${version}.xpi";
        hash = "sha256-sfHDfWKQ3+X0gtjCIb+yJGcfSc8TTMk71sCQJ7mC0Xs=";
    };

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
