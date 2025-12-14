{ ... }:
{
  sane.programs.catgirl-downloader = {
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";

    sandbox.mesaCacheDir = ".cache/catgirldownloader/mesa";
    # configured via ~/.config/catgirldownloader/config.json
  };
}
