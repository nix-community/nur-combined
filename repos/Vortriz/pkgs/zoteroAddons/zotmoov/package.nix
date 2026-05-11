{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "ZotMoov";
    version = "1.2.29";

    src = fetchurl {
        url = "https://github.com/wileyyugioh/zotmoov/releases/download/${version}/zotmoov-${version}-fx.xpi";
        hash = "sha256-DDjziK93E6F4nxEXxLVA/bVj0OsS0fnuUd0nZR1yFl0=";
    };

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
