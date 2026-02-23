{
  config,
  pkgs,
  lib,
  homelab,
  ...
}:
let
  wireguardInterface = "wg0";
  wireguardInterfaceNamespace = "protonvpn0";
  # wireguardGateway = "10.2.0.1";
  inherit (config.networking) hostName;
in
{
  config = lib.mkIf config.services.qbittorrent.enable {
    services.qbittorrent = {
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "toyvo";
            Password_PBKDF2 = "@ByteArray(w/tVwkQ82PheDXAAMg5D7A==:exy5JA4JdCm7pZ6n0cci16mEmZYxSaFe642TmZBvq9MIzps3tnZY7vbUIj3esJNClzy/YrRI4Dkexg1luhSveg==)";
          };
          General.Locale = "en";
        };
      };
      webuiPort = homelab.${hostName}.services.qbittorrent.port;
      group = "multimedia";
      openFirewall = true;
    };
    systemd = {
      services = {
        qbittorrent = {
          bindsTo = [ "wireguard-${wireguardInterface}.service" ];
          requires = [
            "network-online.target"
            "wireguard-${wireguardInterface}.service"
            # "port-forward-qbittorrent.service"
            "proxy-to-qbittorrent.service"
          ];
          serviceConfig.NetworkNamespacePath = "/var/run/netns/${wireguardInterfaceNamespace}";
        };
        # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
        proxy-to-qbittorrent = {
          enable = true;
          description = "Proxy to qBittorrent in Network Namespace";
          requires = [
            "proxy-to-qbittorrent.socket"
          ];
          after = [
            "qbittorrent.service"
            "proxy-to-qbittorrent.socket"
          ];
          unitConfig = {
            JoinsNamespaceOf = "qbittorrent.service";
          };
          serviceConfig = {
            User = "qbittorrent";
            Group = "multimedia";
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
            PrivateNetwork = "yes";
          };
        };
        # port-forward-qbittorrent = {
        #   enable = true;
        #   bindsTo = [ "wireguard-${wireguardInterface}.service" ];
        #   requires = [
        #     "network-online.target"
        #     "wireguard-${wireguardInterface}.service"
        #   ];
        #   after = [ "qbittorrent.service" ];
        #   description = "Port Forwarding for qBittorrent through ProtonVPN";
        #   unitConfig = {
        #     JoinsNamespaceOf = "qbittorrent.service";
        #   };
        #   serviceConfig = {
        #     User = "qbittorrent";
        #     Group = "multimedia";
        #     PrivateNetwork = "yes";
        #     ExecStart = pkgs.writeScript "port-forward-qbittorrent.py" ''
        #       #!${pkgs.python3}/bin/python3
        #       import time
        #       import subprocess

        #       while True:
        #           try:
        #               print(time.strftime("%Y-%m-%d %H:%M:%S"))
        #               udp_result = subprocess.run(
        #                   ["${pkgs.libnatpmp}/bin/natpmpc", "-a", "1", "0", "udp", "60", "-g", "${wireguardGateway}"],
        #                   capture_output=True, text=True
        #               )
        #               tcp_result = subprocess.run(
        #                   ["${pkgs.libnatpmp}/bin/natpmpc", "-a", "1", "0", "tcp", "60", "-g", "${wireguardGateway}"],
        #                   capture_output=True, text=True
        #               )

        #               if udp_result.returncode == 0 and tcp_result.returncode == 0:
        #                   # Extract the port from the TCP result
        #                   for line in tcp_result.stdout.splitlines():
        #                       if line.startswith("Mapped public port"):
        #                           port = int(line.split()[3])
        #                           # TODO: set forwarding port to whatever comes back and ensure the checkbox to use UPnP / NAT-PMP is disabled
        #                           print(f"TCP port {port} mapped successfully")
        #                           break
        #                   # Extract the port from the UDP result
        #                   for line in udp_result.stdout.splitlines():
        #                       if line.startswith("Mapped public port"):
        #                           port = int(line.split()[3])
        #                           # TODO: set forwarding port to whatever comes back and ensure the checkbox to use UPnP / NAT-PMP is disabled
        #                           print(f"UDP port {port} mapped successfully")
        #                           break
        #               else:
        #                   print("ERROR with natpmpc command")
        #                   print("UDP Output:", udp_result.stdout)
        #                   print("TCP Output:", tcp_result.stdout)
        #                   break
        #           except Exception as e:
        #               print(f"Unexpected error: {e}")
        #               break

        #           time.sleep(45)
        #     '';
        #   };
        # };
      };
      # allowing caddy to access qbittorrent in network namespace, a socket is necesarry
      sockets.proxy-to-qbittorrent = {
        enable = true;
        description = "Socket for Proxy to qBittorrent";
        listenStreams = [ (toString config.services.qbittorrent.webuiPort) ];
        wantedBy = [ "sockets.target" ];
      };
    };
  };
}
