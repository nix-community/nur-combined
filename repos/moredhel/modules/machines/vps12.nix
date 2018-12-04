# TopLevel configuration file for my vps12 scaleway server
{ config, pkgs, options, ... }:

let
  secrets = import /etc/nixos/secrets.nix;
  modules = import ../default.nix;
in
{
  imports =
    [
      modules.core.common
      modules.core.pkgs.base
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.nameservers = ["10.100.0.1"];
  networking.hostName = "vps12";
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE
  '';

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 1;


  time.timeZone = "Europe/Amsterdam";

  networking.wireguard.interfaces = {
    wg0 = {                                                                                
      ips = [ "10.100.0.1/24" ];                                                
      privateKey = secrets.wireguard.privateKey;
      listenPort = 51820;
      postSetup = [
        "${pkgs.coreutils}/bin/sleep 3"
        "${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT" # wg0 -> %i
        "${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE"
      ];
      postShutdown = [
        "${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE"];
      # publicKey = "mufxxMJLcvz4BLyIS09PsE9RnFuXFIGKpQRolANxQ1c=";
      peers = secrets.wireguard.peers;
    };                                                                                     
  }; 


  services.keybase.enable = true;
  services.kbfs.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 53443
  # mutual-tls ports for development
  8000 9000];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  # Or disable the firewall altogether.
  networking.firewall.trustedInterfaces = ["wg0"];
  networking.firewall.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  programs.mosh.enable = true;
}
