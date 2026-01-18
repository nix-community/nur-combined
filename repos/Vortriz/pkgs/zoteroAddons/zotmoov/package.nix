{
  lib,
  mkZoteroAddon,
  fetchurl,
}:
mkZoteroAddon rec {
  pname = "ZotMoov";
  version = "1.2.25";

  src = fetchurl {
    url = "https://github.com/wileyyugioh/zotmoov/releases/download/${version}/zotmoov-${version}-fx.xpi";
    hash = "sha256-WnmKB5bR09KpR8KuLCK6rC8Ur2n6+Uw26CaeNzJUj1g=";
  };

  addonId = "zotmoov@wileyy.com";

  meta = {
    description = "Mooves attachments and links them";
    homepage = "https://github.com/wileyyugioh/zotmoov";
    license = lib.licenses.gpl3Only;
  };
}