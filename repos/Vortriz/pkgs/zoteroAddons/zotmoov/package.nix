{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "ZotMoov";
    version = "1.2.28";

    src = fetchurl {
        url = "https://github.com/wileyyugioh/zotmoov/releases/download/${version}/zotmoov-${version}-fx.xpi";
        hash = "sha256-H2zNIXbkAMSzg0CfhlL3qpBG5GY2jbrC+zUH4LEoCTc=";
    };

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
