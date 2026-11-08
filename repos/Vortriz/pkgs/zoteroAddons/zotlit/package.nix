{
    inputs,
    lib,
    mkZoteroAddon,
}:
mkZoteroAddon {
    pname = "ZotLit";
    version = inputs._meta.zotlit.version;

    src = inputs.zotlit;

    addonId = "zotlit@aidenlx.site";

    meta = {
        description = "Bring your Zotero library into Obsidian. Create literature notes, insert citations, and annotate PDFs without leaving your vault.";
        homepage = "https://github.com/aidenlx/zotlit";
        license = lib.licenses.agpl3Plus;
    };
}
