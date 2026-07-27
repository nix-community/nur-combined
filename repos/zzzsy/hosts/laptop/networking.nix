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
          endpoint = "10.134.53.86:20243";
          persistentKeepalive = 25;
          publicKey = "eIbVZ6xaoA0gu7tuOV7IsC8UiE2pmhb1u62zD5Jh3mY=";
        }
      ];
      privateKeyFile = config.vaultix.secrets.wg.path;
      #postUp = ''
      #  ip rule add fwmark 0x800/0x800 table 1145
      #  ip -6 rule add fwmark 0x800/0x800 table 1145
      #'';
      #postDown = ''
      #  ip rule del fwmark 0x800/0x800 table 1145
      #  ip -6 rule del fwmark 0x800/0x800 table 1145
      #'';
    };
  };
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "0cccb752f79f6de5" ];
  };
  programs.openvpn3.enable = true;
  services.resolved.enable = true;
  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };
  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /etc/ssh/ssh_host_ed25519_key
  '';
}
