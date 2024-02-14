# Xray server
# You still need to specify options in abszero.services.xray
{
  imports = [ ./server.nix ];

  abszero.services.xray.enable = true;

  boot.kernel.sysctl = {
    # Taken from https://github.com/bannedbook/fanqiang/blob/master/v2ss/server-cfg/sysctl-bbr-cake.conf
    # It seems that bbr+cake is currently faster than bbrplus and bbrv2 (how
    # weird). Need to periodically check for new updates.
    "fs.file-max" = 655350;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
