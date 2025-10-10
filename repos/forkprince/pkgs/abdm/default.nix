{
  copyDesktopItems,
  autoPatchelfHook,
  makeDesktopItem,
  libappindicator,
  makeWrapper,
  fontconfig,
  alsa-lib,
  fetchurl,
  wayland,
  libXext,
  libXtst,
  libX11,
  stdenv,
  libGL,
  zlib,
  gtk3,
  glib,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenv.mkDerivation rec {
    pname = "ab-download-manager";
    inherit (info) version;

    src = fetchurl {
      url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
      inherit (info) hash;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];
    buildInputs = [
      libappindicator
      fontconfig
      alsa-lib
      wayland
      libXext
      libXtst
      libX11
      libGL
      zlib
      gtk3
      glib
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

    meta = {
      description = "A Download Manager that speeds up your downloads";
      homepage = "https://abdownloadmanager.com/";
      license = lib.licenses.asl20;
      platforms = ["x86_64-linux"];
      maintainers = ["Prinky"];
      mainProgram = "ab-download-manager";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
