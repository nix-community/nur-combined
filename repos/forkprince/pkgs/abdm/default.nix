{
  autoPatchelfHook,
  copyDesktopItems,
  libappindicator,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  fontconfig,
  fetchurl,
  alsa-lib,
  wayland,
  libGL,
  glib,
  gtk3,
  libX11,
  libXext,
  libXtst,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "ab-download-manager";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  inherit (ver) version;

  meta = {
    description = "A Download Manager that speeds up your downloads";
    homepage = "https://abdownloadmanager.com/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [Prinky];
    mainProgram = "ab-download-manager";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;
    })
  else
    stdenvNoCC.mkDerivation rec {
      inherit pname version src meta;

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
      ];
      buildInputs = [
        libappindicator
        libXtst
        libXext
        libX11
        fontconfig
        alsa-lib
        wayland
        libGL
        glib
        gtk3
        zlib
      ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/${pname}
        cp -r ABDownloadManager/* $out/share/${pname}/

        mkdir -p $out/bin
        makeWrapper $out/share/${pname}/bin/ABDownloadManager $out/bin/${pname} \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

        install -Dm644 $out/share/${pname}/lib/ABDownloadManager.png \
          $out/share/icons/hicolor/512x512/apps/${pname}.png

        runHook postInstall
      '';

      desktopItems = makeDesktopItem {
        name = "ab-download-manager";
        desktopName = "AB Download Manager";
        exec = "ab-download-manager";
        startupWMClass = "AB Download Manager";
        genericName = "Download Manager";
        comment = "A Download Manager that speeds up your downloads";
        icon = "ab-download-manager";
        keywords = [
          "download"
          "manager"
          "network"
          "utility"
          "speed"
        ];
        categories = [
          "Network"
          "Utility"
        ];
      };
    }
