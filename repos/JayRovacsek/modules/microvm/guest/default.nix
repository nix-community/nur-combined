{
  networking.useNetworkd = true;

  systemd.network.networks."00-wired" = {
    enable = true;
    matchConfig.Name = "enp*";
    networkConfig.DHCP = "yes";
  };
}
