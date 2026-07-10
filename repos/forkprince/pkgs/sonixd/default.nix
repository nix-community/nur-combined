{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "sonixd";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Full-featured Subsonic/Jellyfin compatible desktop music player";
    homepage = "https://github.com/jeffvli/sonixd";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [onny Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else let
    content = appimageTools.extractType2 {inherit pname version src;};
  in
    appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        install -m 444 -D ${content}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
        cp -r ${content}/usr/share/icons $out/share
      '';

      meta =
        meta
        // {
          mainProgram = "sonixd";
        };
    }
