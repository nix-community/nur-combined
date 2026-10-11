{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "orbolay";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Quick, small, native, multi-platform Discord overlay alternative";
    homepage = "https://github.com/SpikeHD/Orbolay";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "orbolay";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Orbolay";
      categories = ["Network"];
    }
