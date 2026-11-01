{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "ZotLit";
    version = "2.2.0";

    src = fetchurl {
        url = "https://github.com/aidenlx/zotlit/releases/download/zt-${version}/zotlit-zotero-${version}.xpi";
        hash = "sha256-jpagkCNncIh4QMtXxmWu93OAVwaGF3wWY7CBKLqexV4=";
    };

    addonId = "zotlit@aidenlx.site";

    meta = {
        description = "Bring your Zotero library into Obsidian. Create literature notes, insert citations, and annotate PDFs without leaving your vault.";
        homepage = "https://github.com/aidenlx/zotlit";
        license = lib.licenses.agpl3Plus;
    };
}
