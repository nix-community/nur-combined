{
    inputs,
    lib,
    mkZoteroAddon,
}:
mkZoteroAddon {
    pname = "Zotero Scihub";
    version = inputs._meta.zotero-scihub.version;

    src = inputs.zotero-scihub;

    addonId = "scihub@example.com";

    meta = {
        description = "A plugin that will automatically download PDFs of zotero items from sci-hub";
        homepage = "https://github.com/ethanwillis/zotero-scihub";
        license = lib.licenses.agpl3Plus;
    };
}
