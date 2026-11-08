{
    inputs,
    lib,
    mkZoteroAddon,
}:
mkZoteroAddon {
    pname = "Better BibTeX for Zotero";
    version = inputs._meta.zotero-better-bibtex.version;

    src = inputs.zotero-better-bibtex;

    addonId = "better-bibtex@iris-advies.com";

    meta = {
        description = "Make Zotero effective for us LaTeX holdouts";
        homepage = "https://github.com/retorquere/zotero-better-bibtex";
        license = lib.licenses.mit;
    };
}
