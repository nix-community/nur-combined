{ ... }:
{
  sane.programs.confy = {
    sandbox.net = "all";
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/net.kirgroup.confy/mesa";
    sandbox.whitelistDbus.user.own = [ "net.kirgroup.confy" ];
    sandbox.whitelistPortal = [
      # "NetworkMonitor"
      "OpenURI"
    ];
    sandbox.extraEnv.GIO_USE_NETWORK_MONITOR = "netlink";  #< required if portal NetworkMonitor isn't exposed

    persist.byStore.private = [
      ".cache/net.kirgroup.confy"
      # ".local/share/net.kirgroup.confy"  #< empty
    ];
  };
}
