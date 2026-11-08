{
    inputs,
    lib,
    mkZoteroAddon,
}:
mkZoteroAddon {
    pname = "ZotMoov";
    version = inputs._meta.zotmoov.version;

    src = inputs.zotmoov;

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
