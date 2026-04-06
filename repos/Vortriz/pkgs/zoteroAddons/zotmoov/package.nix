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
        hash = "sha256-UfPQWLnMqB697s4CG8Jj/liHiLxNDjp8LW0ZbulL7bk=";
    };

    addonId = "zotmoov@wileyy.com";

    meta = {
        description = "Mooves attachments and links them";
        homepage = "https://github.com/wileyyugioh/zotmoov";
        license = lib.licenses.gpl3Only;
    };
}
