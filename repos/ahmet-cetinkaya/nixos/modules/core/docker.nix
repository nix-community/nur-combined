{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings.live-restore = false;
  };
}
