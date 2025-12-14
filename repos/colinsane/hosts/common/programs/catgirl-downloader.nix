{ ... }:
{
  sane.programs.catgirl-downloader = {
    sandbox.whitelistWayland = true;
    # sandbox.net = "clearnet";
    sandbox.net = "vpn";

    sandbox.mesaCacheDir = ".cache/catgirldownloader/mesa";

    sandbox.extraHomePaths = [
      "tmp"  # for saving photos
    ];

    persist.byStore.ephemeral = [
      ".config/catgirldownloader"
    ];
  };
}
