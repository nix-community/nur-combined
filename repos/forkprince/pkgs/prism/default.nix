{
  libayatana-appindicator,
  webkitgtk_4_1,
  stdenvNoCC,
  fetchurl,
  openssl,
  stdenv,
  ffmpeg,
  libGL,
  gtk3,
  glib,
  dbus,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "prism";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Fast, free, open-source multi-connection download manager with browser integration and video downloads";
    homepage = "https://prismdl.site/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "prism";
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

      desktopName = "Prism";
      desktopId = "Prism";
      startupWMClass = "prism";
      categories = ["Network" "Utility"];
      extraDesktopItem = {
        mimeTypes = ["application/x-bittorrent" "x-scheme-handler/magnet"];
      };

      extraPkgs = [
        libayatana-appindicator
        stdenv.cc.cc.lib
        webkitgtk_4_1
        openssl
        ffmpeg
        libGL
        dbus
        gtk3
        glib
      ];
    }
