{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  webkitgtk_4_1,
}:

stdenvNoCC.mkDerivation {
  pname = "orb-forge-gui";
  version = "0-unstable-2025-09-13";

  src = fetchurl {
    # to update, archive this page: https://orb.net/the-forge/early-access/orb-beta-for-linux-(gui)
    url = "https://web.archive.org/web/20250710224801if_/https://pkgs.orb.net/earlyaccess/linux/orb-desktop";
    hash = "sha256-skMG4J3yV9klW+pX9GivamHTupRJ8JlqBueTzMAYB8o=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    webkitgtk_4_1
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp $src $out/bin/orb-forge-gui
    chmod +x $out/bin/orb-forge-gui
  '';

  meta = {
    description = "Orb beta for Linux (GUI)";
    changelog = "https://orb.net/the-forge/early-access/orb-beta-for-linux-(gui)";
    homepage = "https://orb.net/the-forge/early-access/orb-beta-for-linux-(gui)";
    mainProgram = "orb-forge-gui";
    license = lib.licenses.unfreeRedistributable;
    platform = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [
      gepbird
    ];
  };
}
