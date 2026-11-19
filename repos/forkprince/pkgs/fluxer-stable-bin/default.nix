# Modified from https://github.com/NixOS/nixpkgs/pull/490554
{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "fluxer-stable-bin";
  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;

  meta = {
    description = "Fluxer desktop client";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "fluxer-stable-bin";
    maintainers = with lib.maintainers; [WoutFontaine Prinky];
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

      desktopId = "app.fluxer.FluxerDesktop";
      desktopName = "Fluxer";
      icon = "fluxer";
      startupWMClass = "app.fluxer.FluxerDesktop";
      categories = ["InstantMessaging"];

      profile = ''
        export FLUXER_DISABLE_DESKTOP_FILE=1
      '';
    }
