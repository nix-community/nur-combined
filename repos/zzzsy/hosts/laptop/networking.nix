{ config, pkgs, ... }:
{
  vaultix.secrets.wg = { };
  networking = {
    useDHCP = false;
    firewall.enable = false;
    wireless.iwd.enable = true;
    usePredictableInterfaceNames = false;
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
  services.dae = {
    enable = true;
    package = pkgs.my.dae;
    configFile = "/home/zzzsy/.config/dae/config.dae";
  };
  networking.wg-quick.interfaces = {
    wg-vpn = {
      autostart = false;
      address = [
        "172.20.0.3/32"
        "fd10:cafe::3/128"
      ];
      mtu = 1420;
      # table = "1145";
      peers = [
        {
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "10.134.53.86:20243";
          persistentKeepalive = 25;
          publicKey = "4kUglMcTKTLJ0UgrSUoFDM39D0Csawh8qX02ryU9kXA=";
        }
      ];
      privateKeyFile = config.vaultix.secrets.wg.path;
      # postUp = ''
      #   ip rule add fwmark 0x800/0x800 table 1145
      #   ip -6 rule add fwmark 0x800/0x800 table 1145
      # '';
      # postDown = ''
      #   ip rule del fwmark 0x800/0x800 table 1145
      #   ip -6 rule del fwmark 0x800/0x800 table 1145
      # '';
    };
  };
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "0cccb752f79f6de5" ];
  };
  programs.openvpn3.enable = true;
  services.resolved.enable = true;
}
