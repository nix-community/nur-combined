{
  sources,

  appimageTools,
  lib,
}:
appimageTools.wrapType2 {
  inherit (sources.deemix-gui-bin) pname version src;

  extraInstallCommands = ''
    mv $out/bin/${sources.deemix-gui-bin.pname} $out/bin/deemix-gui
  '';

  meta = {
    description = "An electron app that wraps deemix-webui and lets you use the deemix-js library";
    homepage = "https://gitlab.com/RemixDev/deemix-gui";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "deemix-gui";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
