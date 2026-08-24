{
  fetchurl,
  appimageTools,
  lib,
}:
appimageTools.wrapType2 (finalAttrs: {
  pname = "deemix-gui-bin";
  version = "3.6.6";
  src = fetchurl {
    url = "https://archive.org/download/deemix/gui/linux-x64-latest.AppImage";
    sha256 = "sha256-e2neemsAzGniBpXIPYbKk5LQHoYLvFj5/8QszCcoTYM=";
  };

  extraInstallCommands = ''
    mv $out/bin/${finalAttrs.pname} $out/bin/deemix-gui
  '';

  meta = {
    description = "An electron app that wraps deemix-webui and lets you use the deemix-js library";
    homepage = "https://gitlab.com/RemixDev/deemix-gui";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "deemix-gui";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
