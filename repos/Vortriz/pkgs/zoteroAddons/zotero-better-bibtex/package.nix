{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "zotero-better-bibtex";
    version = "7.0.68";

    src = fetchurl {
        url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${version}/zotero-better-bibtex-${version}.xpi";
        sha256 = "sha256-Nr6tSqeMqvmMl52crlPTegyquVbT1Y6nnve+muvEKT8=";
    };

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
