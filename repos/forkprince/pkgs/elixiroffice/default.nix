{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "elixiroffice";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Open source office suite for users used to MS Office";
    homepage = "https://github.com/leag1234/ElixirOffice";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
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

      desktopName = "ElixirOffice";
      categories = ["Office"];
      startupWMClass = "org.elixiroffice.desktop";
    }
