{
  flake.modules.nixos.wgmesh =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options.wgmesh = {
        configFile = lib.mkOption {
          type = lib.types.str;
        };
        image = lib.mkOption {
          type = lib.types.str;
          default = "ghcr.io/asoul-rec/wg-mesh:master@sha256:1e2f71ae1af31694c573a9903e43db85d0df285475c02c2f6ba7e3cc399e6ed2"; # x86
        };
      };
      config = {

        virtualisation.oci-containers.containers.wg-mesh = {
          image = config.wgmesh.image;
          ports = [
            "58833:51820/udp"
            "127.0.0.1:19586:9586/tcp"
          ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--cap-add=NET_RAW"
            "--sysctl=net.ipv4.ip_forward=1"
            "--sysctl=net.ipv6.conf.all.forwarding=1"
          ];
          volumes = [
            "${config.wgmesh.configFile}:/app/config.json:rw"
          ];
        };

        systemd.sockets.wgmesh-metrics-proxy = {
          listenStreams = [ "[::]:9586" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            BindIPv6Only = "ipv6-only";
          };
        };

        systemd.services.wgmesh-metrics-proxy = {
          description = "Proxy for wg-mesh Metrics IPv6 to IPv4";
          requires = [ "wgmesh-metrics-proxy.socket" ];
          serviceConfig = {
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:19586";
          };
        };

        networking.firewall = {
          allowedUDPPorts = [ 58833 ];
        };
      };
    };
}
