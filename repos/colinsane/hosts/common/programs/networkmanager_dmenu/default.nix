# source: <https://github.com/firecat53/networkmanager-dmenu>
{ ... }:
{
  sane.programs.networkmanager_dmenu = {
    sandbox.method = "bwrap";
    sandbox.isolatePids = false;  #< so it can know that NetworkManager really is running... (?)
    sandbox.whitelistDbus = [
      "system"
    ];
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".cache/rofi"
      ".config/rofi"
    ];
    suggestedPrograms = [
      "pidof"
    ];

    fs.".config/networkmanager-dmenu/config.ini".symlink.target = ./config.ini;
  };
}
