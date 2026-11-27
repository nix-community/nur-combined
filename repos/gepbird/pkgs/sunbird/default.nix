{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
}:

let
  pname = "sunbird";
  version = "2233";
  loader = fetchurl {
    name = "libphoenix-2026.11.26.2140-47990f4.so";
    url = "https://assets.sunbird.tools/plugins/libphoenix-linux-x86_64.so";
    hash = "sha256-Pm34CKy8EP/Ap0o7C/j7wLLteZGWfQIErt+I3HUYFn8=";
  };
  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Sunbird";
    exec = "sunbird %U";
    icon = pname;
    categories = [
      "Network"
      "InstantMessaging"
    ];
  };
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname version;

  src = fetchurl {
    url = "https://dl.redeem.saarland/desktop/${version}/linux-x64.AppImage";
    hash = "sha256-c4CO5T2i7w3JhFcYQL7A7TMR+p4u8SNsoBxc2C9Vmr4=";
  };

  profile = ''
    export LD_PRELOAD="${loader}''${LD_PRELOAD:+:$LD_PRELOAD}"
  '';

  extraInstallCommands = ''
    install -Dm644 ${desktopItem}/share/applications/sunbird.desktop $out/share/applications/sunbird.desktop
    install -Dm644 ${finalAttrs.contents}/com.discord.libdiscord.png $out/share/icons/hicolor/256x256/apps/sunbird.png
  '';

  meta = {
    description = "Discord Desktop Phoenix with the Sunbird plugin runtime";
    homepage = "https://sunbird.tools/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sunbird";
    maintainers = with lib.maintainers; [
      gepbird
    ];
  };
})
