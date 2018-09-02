{ config, pkgs, lib, ... }:

with import ./vars.nix;

{
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  networking = {
    hostName = "argon"; # Define your hostname.
    firewall.allowedTCPPorts = [ 80 443 995 7777 18903 25565 25566 ccfusePort ];

    nat = {
      enable = true;
      internalIPs = [ "10.8.0.0/8" ];
      externalInterface = "ens18";
    };
  };

  services.openvpn.servers.server = {
    config = ''
      port 995
      proto tcp

      dev tun

      ca /home/casper/.openvpn/ca.crt
      cert /home/casper/.openvpn/server.crt
      key /home/casper/.openvpn/server.key
      dh /home/casper/.openvpn/dh.pem

      server 10.8.0.0 255.255.255.0

      ifconfig 10.8.0.1 10.8.0.2
      ifconfig-pool-persist ipp.txt

      push "redirect-gateway def1 bypass-dhcp"

      push "dhcp-option DNS 37.235.1.174"
      push "dhcp-option DNS 37.235.1.177"

      keepalive 10 120

      tls-auth /home/casper/.openvpn/ta.key 0
      key-direction 0

      cipher AES-256-CBC
      auth SHA256

      compress lz4-v2

      user nobody
      group nobody

      persist-key
      persist-tun

      verb 3
    '';
  };
}
