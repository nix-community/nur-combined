{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "SciPDF For Zotero";
    version = "8.0.2";

    src = fetchurl {
        url = "https://github.com/syt2/zotero-scipdf/releases/download/V${version}/sci-pdf.xpi";
        hash = "sha256-bWNehOdmXZNLRDLdR65IBNkxxzSaWnomgI6mjLQU69E=";
    };

    addonId = "scipdf@ytshen.com";

    meta = {
        description = "Download PDF from Sci-Hub automatically (For Zotero7)";
        homepage = "https://github.com/syt2/zotero-scipdf";
        license = lib.licenses.agpl3Plus;
    };
}
