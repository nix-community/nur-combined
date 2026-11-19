{
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  lib.helper.mkAppImage rec {
    pname = "kryoto-desktop";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    desktopName = "Kryoto Desktop";
    desktopComment = "Desktop client";
    exec = pname;
    icon = pname;
    startupWMClass = pname;
    categories = ["Game"];
    terminal = false;

    extraBwrapArgs = ["--unsetenv GIO_EXTRA_MODULES"];

    meta = {
      description = "Find a game, download it and play it";
      homepage = "https://github.com/kyrotooooo/kryoto-desktop";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
