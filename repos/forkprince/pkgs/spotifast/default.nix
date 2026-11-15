{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "spotifast";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Fast, native Spotify client";
    homepage = "https://spotifast.rocks/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "spotifast";
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

      desktopName = "Spotifast";
      startupWMClass = "spotifast";
      categories = ["AudioVideo" "Audio" "Player"];
    }
