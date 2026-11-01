# tpictures (scanitall's web app). The app itself is deployed outside the system config: the
# service runs whatever the tpictures profile points at, set with
#   nix build --profile /nix/var/nix/profiles/tpictures <scanitall>#tpictures
{ vacuModules, ... }:
let
  profile = "/nix/var/nix/profiles/tpictures";
  socketDir = "/run/tpictures";
in
{
  imports = [
    vacuModules.sops
    vacuModules.caddy-hsts
    vacuModules.tpictures-oauth
  ];

  services.caddy.enable = true;
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };

  vacu.oauthProxy.instances.tpictures = {
    configureCaddy = true;
    caddyConfig = ''
      reverse_proxy unix/${socketDir}/http.sock
    '';
  };
  services.caddy.virtualHosts."tpictures.shelvacu.com".vacu.hsts = "preload";

  users.users.tpictures = {
    isSystemUser = true;
    group = "tpictures";
    # some scans in /t-pictures are only group-readable by users
    extraGroups = [ "users" ];
  };
  users.groups.tpictures = { };
  users.users.caddy.extraGroups = [ "tpictures" ];

  systemd.services.tpictures = {
    description = "tpictures web app";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    unitConfig = {
      ConditionPathExists = "${profile}/bin/tpictures";
      RequiresMountsFor = "/t-pictures";
    };
    environment = {
      TPICTURES_ROOT = "/t-pictures";
      TPICTURES_STATE = "/var/lib/tpictures";
      TPICTURES_SOCKET = "${socketDir}/http.sock";
      TPICTURES_ADMINS = "shelvacu";
    };
    serviceConfig = {
      ExecStart = "${profile}/bin/tpictures";
      User = "tpictures";
      Group = "tpictures";
      StateDirectory = "tpictures";
      RuntimeDirectory = "tpictures";
      RuntimeDirectoryMode = "0750";
      UMask = "0007";
      Restart = "on-failure";
      RestartSec = 5;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
