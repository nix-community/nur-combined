{
  fetchurl,
  appimageTools,
  lib,
  ...
}: let
  pname = "Fladder";
  version = "0.8.0";
  src = fetchurl {
    url = "https://github.com/DonutWare/${pname}/releases/download/v${version}/${pname}-Linux-${version}.AppImage";
    hash = "sha256-uU/QTfAF22d4RPkv7rJrOkn1/LBwMJRv0wLnolxDD/Y=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    src = appimageContents;
    extraPkgs = pkgs:
      with pkgs; [
        mpv
        libepoxy
        libva
        mesa
      ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/*.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/*.png $out/share/pixmaps/
    '';

    meta = with lib; {
      description = "A Simple Jellyfin Frontend built on top of Flutter.";
      homepage = "https://github.com/DonutWare/Fladder";
      platforms = with platforms; (intersectLists x86_64 linux);
      license = with licenses; [gpl3Only];
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [binaryBytecode];
    };
  }
