{ ... }:
{
  sane.programs.catgirl-downloader = {
    sandbox.whitelistWayland = true;
    # sandbox.net = "clearnet";
    sandbox.net = "vpn";

    sandbox.mesaCacheDir = ".cache/catgirldownloader/mesa";
    # configured via ~/.config/catgirldownloader/config.json

    sandbox.extraHomePaths = [
      "tmp"  # for saving photos
    ];
  };
}
