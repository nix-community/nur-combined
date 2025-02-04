{ ... }:
{
  sane.programs.confy = {
    sandbox.net = "all";
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/net.kirgroup.confy/mesa";
    sandbox.whitelistDbus.user.own = [ "net.kirgroup.confy" ];
    sandbox.whitelistPortal = [
      "NetworkMonitor"
      "OpenURI"
    ];

    persist.byStore.private = [
      ".cache/net.kirgroup.confy"
      # ".local/share/net.kirgroup.confy"  #< empty
    ];
  };
}
