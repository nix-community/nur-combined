{
    lib,
    mkZoteroAddon,
    fetchurl,
}:
mkZoteroAddon rec {
    pname = "ZotMoov";
    version = "1.2.32";

    src = fetchurl {
        url = "https://github.com/wileyyugioh/zotmoov/releases/download/${version}/zotmoov-${version}-fx.xpi";
        hash = "sha256-d3DcLGLSqqsmYv10Aq+t0Fg4e/9pV4SBrAOb/AUOzCs=";
    };

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
