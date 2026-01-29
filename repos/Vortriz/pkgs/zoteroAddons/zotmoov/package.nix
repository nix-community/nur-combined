{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "ZotMoov";
    version = "1.2.26";

    src = fetchurl {
        url = "https://github.com/wileyyugioh/zotmoov/releases/download/${version}/zotmoov-${version}-fx.xpi";
        hash = "sha256-y89Pun0exbMa+Wq7BPdaBSkMtqmi3nHS5AH/qAuiyi4=";
    };

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
