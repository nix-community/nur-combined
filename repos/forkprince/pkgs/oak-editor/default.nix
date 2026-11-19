{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "oak-editor";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "A free non-linear video editor for Linux, macOS, and Windows";
    homepage = "https://github.com/OakVideoEditorCommunity/oak";
    changelog = "https://github.com/OakVideoEditorCommunity/oak/releases/tag/v${version}";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "oak-editor";
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

      desktopName = "Oak Video Editor";
      categories = ["AudioVideo" "Video" "AudioVideoEditing"];
    }
