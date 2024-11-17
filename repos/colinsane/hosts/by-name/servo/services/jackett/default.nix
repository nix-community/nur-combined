{ config, lib, pkgs, ... }:

let
  cfg = config.services.jackett;
in
{
  sane.persist.sys.byStore.private = [
    # TODO: mode? we only need this to save Indexer creds ==> migrate to config?
    { user = "jackett"; group = "jackett"; path = "/var/lib/jackett"; method = "bind"; }
  ];
  services.jackett.enable = true;

  # run this behind the OVPN static VPN
  sane.netns.ovpns.services = [ "jackett" ];
  systemd.services.jackett = {
    serviceConfig.ExecStartPre = [
      # abort if public IP is not as expected
      "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${config.sane.netns.ovpns.wg.address.ipv4}"
    ];
    # patch in `--ListenPublic` so that it's reachable from the netns veth.
    # this also makes it reachable from the VPN pub address. oh well.
    serviceConfig.ExecStart = lib.mkForce "${lib.getExe' cfg.package "Jackett"} --ListenPublic --NoUpdates --DataFolder '${cfg.dataDir}'";
    serviceConfig.RestartSec = "30s";

    # hardening (systemd-analyze security jackett)
    # TODO: upstream into nixpkgs
    serviceConfig.StateDirectory = "jackett";
    serviceConfig.LockPersonality = true;
    serviceConfig.NoNewPrivileges = true;
    # serviceConfig.MemoryDenyWriteExecute = true;  #< Failed to create CoreCLR, HRESULT: 0x80004005
    serviceConfig.PrivateDevices = true;
    serviceConfig.PrivateMounts = true;
    serviceConfig.PrivateTmp = true;
    serviceConfig.PrivateUsers = true;
    serviceConfig.ProcSubset = "pid";
    serviceConfig.ProtectClock = true;
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;
    serviceConfig.ProtectHostname = true;
    serviceConfig.ProtectKernelLogs = true;
    serviceConfig.ProtectKernelModules = true;
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectProc = "invisible";
    serviceConfig.ProtectSystem = "strict";
    serviceConfig.RemoveIPC = true;
    serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    serviceConfig.RestrictNamespaces = true;
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [ "@system-service" "~@privileged" ];
  };

  # jackett torrent search
  services.nginx.virtualHosts."jackett.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/" = {
      proxyPass = "http://${config.sane.netns.ovpns.veth.netns.ipv4}:9117";
      recommendedProxySettings = true;
    };
    locations."= /robots.txt".extraConfig = ''
      return 200 "User-agent: *\nDisallow: /\n";
    '';
  };

  sane.dns.zones."uninsane.org".inet.CNAME."jackett" = "native";
}

