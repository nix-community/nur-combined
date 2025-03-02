{ config, pkgs, ... }:
{
  sops.secrets = {
    "wg" = { };
    "wg1" = { };
  };
  networking = {
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = true;
  };
  services.dae = {
    enable = true;
    package = pkgs.dae-unstable;
    configFile = "/home/zzzsy/.config/dae/config.dae";
  };
  networking.wg-quick.interfaces = {
    wg-vpn = {
      autostart = false;
      address = [
        "172.11.0.3/32"
      ];
      mtu = 1420;
      # table = "1145";
      peers = [
        {
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "10.132.24.24:20243";
          persistentKeepalive = 25;
          publicKey = "eIbVZ6xaoA0gu7tuOV7IsC8UiE2pmhb1u62zD5Jh3mY=";
        }
      ];
      privateKeyFile = config.sops.secrets."wg".path;
      #postUp = ''
      #  ip rule add fwmark 0x800/0x800 table 1145
      #  ip -6 rule add fwmark 0x800/0x800 table 1145
      #'';
      #postDown = ''
      #  ip rule del fwmark 0x800/0x800 table 1145
      #  ip -6 rule del fwmark 0x800/0x800 table 1145
      #'';
    };
    wg-zx = {
      autostart = false;
      address = [
        "172.12.0.1/32"
      ];
      mtu = 1420;
      peers = [
      {
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "10.134.48.153:20278";
        persistentKeepalive = 25;
        publicKey = "i9aFPFalqrYrJcdMAl6eVQ1gYdP0A2+X4rVZ2w+ci2c=";
      }
      ];
      privateKeyFile = config.sops.secrets."wg1".path;
    };
  };
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "0cccb752f79f6de5" ];
  };
}
