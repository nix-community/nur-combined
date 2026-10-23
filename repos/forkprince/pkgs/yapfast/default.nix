{
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  pname = "yapfast";
in
  lib.helper.mkAppImage {
    inherit pname;
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    meta = {
      description = "Native Discord client that stays light on memory";
      homepage = "https://github.com/yapfast/yapfast";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [Prinky];
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };

    desktopId = "io.github.yapfast.Yapfast";
    desktopName = "Yapfast";
    desktopComment = "Chat and voice for Matrix and Discord";
    categories = ["Network" "InstantMessaging" "Chat"];
    icon = "io.github.yapfast.Yapfast";
  }
