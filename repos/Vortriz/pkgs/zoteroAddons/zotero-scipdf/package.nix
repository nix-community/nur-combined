{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "zotero-scipdf";
    version = "1.3.0";

    src = fetchurl {
        url = "https://github.com/syt2/zotero-scipdf/releases/download/V${version}/sci-pdf.xpi";
        sha256 = "sha256-Z0OVtN7JHmvfE0hZ6rQ6VUgLFJPF3hnewJn/iQ+Ma8c=";
    };

    addonId = "scipdf@ytshen.com";

    meta = {
        description = "Download PDF from Sci-Hub automatically (For Zotero7)";
        homepage = "https://github.com/syt2/zotero-scipdf";
        license = lib.licenses.agpl3Plus;
    };
}
