{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "Better BibTeX for Zotero";
    version = "8.0.25";

    src = fetchurl {
        url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${version}/zotero-better-bibtex-${version}.xpi";
        hash = "sha256-2jiiZL7eX7538YsJcNs8gQLRhji7oxhKo1ANrVhyfXM=";
    };

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
