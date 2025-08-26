{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  webkitgtk_4_1,

  version ? "0-unstable-2025-07-26",
  # URL is unstable, expect hash mismatches
  url ? "https://pkgs.orb.net/earlyaccess/linux/orb-desktop",
  hash ? "sha256-kyGrEsjMxU2ucKHqYMIyjqZvghqkQcPBhdzk5SN/ITM=",
}:

stdenvNoCC.mkDerivation {
  pname = "orb-forge-gui";
  inherit version;

  src = fetchurl {
    inherit url hash;
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
