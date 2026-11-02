{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "folio-studio";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Free InDesign alternative for page layout and publishing";
    homepage = "https://tenzen.studio/folio/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "folio-studio";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [undmg];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Folio Studio";
      desktopId = "org.tenzen.folio-studio";
      categories = ["Office"];
    }
