{
  flake.modules.nixos.mc =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {

      systemd.sockets.mc-metrics-proxy = {
        listenStreams = [
          "[fdcc::8]:19565"
        ];
        wantedBy = [ "sockets.target" ];
      };
      systemd.sockets.mc-rcon-proxy = {
        listenStreams = [
          "[fdcc::8]:25575"
        ];
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          BindIPv6Only = "ipv6-only";
        };
      };
      systemd.services.mc-metrics-proxy = {
        description = "Proxy for MC Metrics IPv6 to IPv4";
        requires = [ "mc-metrics-proxy.socket" ];
        serviceConfig = {
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:19565";
        };
      };
      systemd.services.mc-rcon-proxy = {
        description = "Proxy for MC Metrics IPv6 to IPv4";
        requires = [ "mc-rcon-proxy.socket" ];
        serviceConfig = {
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:25575";
        };
      };
      networking.firewall.allowedTCPPorts = [ 25565 ];
      virtualisation.oci-containers.containers."mc-server-new-steam-trip" = {
        image = "container-registry.oracle.com/graalvm/jdk:21";
        ports = [
          "25565:25565"
          "25575:25575"
          "19565:19565"
        ];
        volumes = [
          "/var/lib/new-steam-trip:/data"
        ];
        workdir = "/data";
        cmd = [
          "sh"
          "run.sh"
        ];
      };
    };
}
