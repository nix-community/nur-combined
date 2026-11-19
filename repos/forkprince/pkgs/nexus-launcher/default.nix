{
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  lib.helper.mkAppImage rec {
    pname = "nexus-launcher";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    desktopName = "Nexus Launcher";
    desktopId = "xodus-nexus";
    exec = "${pname} --no-sandbox %U";
    icon = "xodus-nexus";
    startupWMClass = "Nexus Launcher";
    categories = ["Game"];

    meta = {
      description = "Open-source Xbox-inspired launcher for Microsoft Store games on Linux";
      homepage = "https://github.com/domsvoboda/nexus-launcher";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
      platforms = ["x86_64-linux"];
      mainProgram = pname;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
