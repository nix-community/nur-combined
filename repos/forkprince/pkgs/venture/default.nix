{
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  inherit (ver) version;
  src = fetchurl (lib.helper.getSingle ver);
in
  lib.helper.mkAppImage {
    pname = "venture";

    inherit version src;

    desktopName = "Venture";
    desktopId = "org.venture_emu.Venture";
    exec = "venture %U";
    categories = ["Game"];
    icon = "org.venture_emu.Venture";
    startupWMClass = "venture";

    meta = {
      description = "A Meta Quest emulator for PC VR";
      homepage = "https://venture-emu.org/";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [Prinky];
      platforms = ["x86_64-linux"];
      mainProgram = "venture";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
