{ ... }:
{
  sane.programs.waifu-downloader = {
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";

    sandbox.mesaCacheDir = ".cache/waifudownloader/mesa";

    sandbox.extraHomePaths = [
      "tmp"  # for saving photos
    ];

    persist.byStore.ephemeral = [
      ".config/waifudownloader"
    ];
  };
}
