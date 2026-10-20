{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "helixnotes";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "A local, open-source Markdown note-taking app.";
    homepage = "https://helixnotes.com";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "helixnotes";
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

      desktopName = "HelixNotes";
      desktopId = "HelixNotes";
      categories = ["Utility" "Office"];
      startupWMClass = "helixnotes";
    }
