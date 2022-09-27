{config, ...}:
{
  services.zerotierone = {
    enable = true;
    port = 6969;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.firewall.trustedInterfaces = [ "ztppi77yi3" ];
  services.dnsmasq.extraConfig = ''
address=/controlplane.${config.networking.domain}/192.168.69.1
address=/whiterun.${config.networking.domain}/192.168.69.1
address=/riverwood.${config.networking.domain}/192.168.69.2
address=/xiaomi.${config.networking.domain}/192.168.69.4
  '';
}
