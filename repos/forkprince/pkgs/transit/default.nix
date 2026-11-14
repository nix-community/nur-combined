{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "transit";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "A free, open-source digital audio workstation (DAW) written in Rust";
    homepage = "https://github.com/transit-audio/transit";
    changelog = "https://github.com/transit-audio/transit/releases/tag/v${version}";
    license = with lib.licenses; [asl20 mit];
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "transit";
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

      desktopName = "transit";
      exec = "transit %F";
      startupWMClass = "dev.derekmwright.transit";
      categories = ["AudioVideo" "Audio" "Midi" "Mixer" "Sequencer" "Recorder"];
      extraDesktopItem = {
        genericName = "Digital Audio Workstation";
        comment = "transit DAW";
        keywords = ["daw" "audio" "mixer" "recording" "multitrack" "midi" "editor" "music"];
        mimeTypes = ["application/x-transit-session"];
      };
    }
