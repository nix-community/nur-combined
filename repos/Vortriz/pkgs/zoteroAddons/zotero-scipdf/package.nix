{
    inputs,
    lib,
    mkZoteroAddon,
}:
mkZoteroAddon {
    pname = "SciPDF For Zotero";
    version = inputs._meta.zotero-scipdf.version;

    src = inputs.zotero-scipdf;

    addonId = "scipdf@ytshen.com";

    meta = {
        description = "Download PDF from Sci-Hub automatically (For Zotero7)";
        homepage = "https://github.com/syt2/zotero-scipdf";
        license = lib.licenses.agpl3Plus;
    };
}
