{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "Better BibTeX for Zotero";
    version = "9.0.6";

    src = fetchurl {
        url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${version}/zotero-better-bibtex-${version}.xpi";
        hash = "sha256-1OcAXBOGqzdOQGCpRgdF/dhHM5ZBrNiV27B/yKRXtFE=";
    };

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
