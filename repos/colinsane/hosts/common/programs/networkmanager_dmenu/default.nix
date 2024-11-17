# source: <https://github.com/firecat53/networkmanager-dmenu>
{ ... }:
{
  sane.programs.networkmanager_dmenu = {
    # sandbox.keepPidsAndProc = true;  #< else it can't connect to NetworkManager (?)
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
