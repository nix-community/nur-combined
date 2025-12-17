{
    lib,
    mkZoteroAddon,
    fetchFromGitHub,
}:
mkZoteroAddon {
    pname = "SciPDF For Zotero";
    version = "1.3.0";

    src = fetchFromGitHub {
        owner = "syt2";
        repo = "zotero-scipdf";
        tag = "1.3.0";
        sha256 = "sha256-Z0OVtN7JHmvfE0hZ6rQ6VUgLFJPF3hnewJn/iQ+Ma8c=";
    };

    addonId = "scipdf@ytshen.com";

    meta = {
        description = "Download PDF from Sci-Hub automatically (For Zotero7)";
        homepage = "https://github.com/syt2/zotero-scipdf";
        license = lib.licenses.agpl3Plus;
    };
}
