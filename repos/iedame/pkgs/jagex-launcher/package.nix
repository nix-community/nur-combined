# The Jagex Launcher, for RuneScape and Old School RuneScape. Jagex ships
# only a Linux AppImage (a beta), so it is wrapped with appimageTools.
#
# To update: bump `version`, and get the new hash with
# `nix-prefetch-url <the url>`.
{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "jagex-launcher";
  version = "0.1.8";

  src = fetchurl {
    url = "https://rs-launcher-updates.runescape.com/production/linux/x64/releases/${version}/jagex-launcher-beta-linux-x86_64.AppImage";
    hash = "sha256-86ZSfIIwIvDHrBRIrZClpfUSKBasS3jMDjo/9nORmEs=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The .desktop entry and icons come out of the AppImage, so the launcher
  # shows up in the application menu; Exec= points at the wrapper rather
  # than the AppImage's internal AppRun.
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Official Jagex Launcher for RuneScape and Old School RuneScape (Linux beta)";
    homepage = "https://www.runescape.com/launcher";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "jagex-launcher";
  };
}
