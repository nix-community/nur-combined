{
  pkgs,
  sources,
  ...
}:
pkgs.appimageTools.wrapType2 {
  name = "deemix-gui";
  inherit (sources.deemix-gui-bin) src;

  meta = with pkgs.lib; {
    description = "An electron app that wraps deemix-webui and lets you use the deemix-js library";
    homepage = "https://gitlab.com/RemixDev/deemix-gui";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
  };
}
