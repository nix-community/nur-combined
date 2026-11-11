{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "sonora";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "A native, familiar music streaming client";
    homepage = "https://sonorahq.org/";
    changelog = "https://github.com/sonorahq/sonora/releases/tag/v${version}";
    license = with lib.licenses; [
      gpl3Plus
      ofl
      isc
    ];
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ ["aarch64-darwin"];
    mainProgram = "sonora";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Sonora";
      icon = "sonora";
      startupWMClass = "sonora";
      categories = ["AudioVideo" "Audio" "Player"];
      extraDesktopItem = {
        genericName = "Music Player";
        keywords = ["music" "spotify" "audio" "player"];
        mimeTypes = [
          "x-scheme-handler/sonora"
          "x-scheme-handler/spotify"
          "x-scheme-handler/deezer"
          "x-scheme-handler/tidal"
          "audio/mpeg"
          "audio/flac"
          "audio/mp4"
          "audio/aac"
          "audio/ogg"
          "audio/opus"
          "audio/x-wav"
          "audio/x-aiff"
          "audio/webm"
          "audio/x-matroska"
          "audio/x-wavpack"
          "audio/x-ape"
        ];
      };
    }
