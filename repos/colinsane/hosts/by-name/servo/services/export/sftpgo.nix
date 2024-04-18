# docs:
# - <https://github.com/drakkan/sftpgo>
# - config options: <https://github.com/drakkan/sftpgo/blob/main/docs/full-configuration.md>
# - config defaults: <https://github.com/drakkan/sftpgo/blob/main/sftpgo.json>
# - nixos options: <repo:nixos/nixpkgs:nixos/modules/services/web-apps/sftpgo.nix>
# - nixos example: <repo:nixos/nixpkgs:nixos/tests/sftpgo.nix>
#
# sftpgo is a FTP server that also supports WebDAV, SFTP, and web clients.

{ config, lib, pkgs, sane-lib, ... }:
let
  sftpgo_external_auth_hook = pkgs.static-nix-shell.mkPython3Bin {
    pname = "sftpgo_external_auth_hook";
    srcRoot = ./.;
  };
in
{
  # Client initiates a FTP "control connection" on port 21.
  # - this handles the client -> server commands, and the server -> client status, but not the actual data
  # - file data, directory listings, etc need to be transferred on an ephemeral "data port".
  # - 50000-50100 is a common port range for this.
  #   50000 is used by soulseek.
  sane.ports.ports = {
    "21" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      # visibleTo.wan = true;
      description = "colin-FTP server";
    };
    "990" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      visibleTo.wan = true;
      description = "colin-FTPS server";
    };
  } // (sane-lib.mapToAttrs
    (port: {
      name = builtins.toString port;
      value = {
        protocol = [ "tcp" ];
        visibleTo.lan = true;
        visibleTo.wan = true;
        description = "colin-FTP server data port range";
      };
    })
    (lib.range 50050 50100)
  );

  # use nginx/acme to produce a cert for FTPS
  services.nginx.virtualHosts."ftp.uninsane.org" = {
    addSSL = true;
    enableACME = true;
  };
  sane.dns.zones."uninsane.org".inet.CNAME."ftp" = "native";

  services.sftpgo = {
    enable = true;
    group = "export";
    settings = {
      ftpd = {
        bindings = [
          {
            # binding this means any wireguard client can connect
            address = "10.0.10.5";
            port = 21;
            debug = true;
          }
          {
            # binding this means any LAN client can connect (also WAN traffic forwarded from the gateway)
            address = "10.78.79.51";
            port = 21;
            debug = true;
          }
          {
            # binding this means any wireguard client can connect
            address = "10.0.10.5";
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
          {
            # binding this means any LAN client can connect (also WAN traffic forwarded from the gateway)
            address = "10.78.79.51";
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
        ];

        # active mode is susceptible to "bounce attacks", without much benefit over passive mode
        disable_active_mode = true;
        hash_support = true;
        passive_port_range = {
          start = 50050;
          end = 50100;
        };

        certificate_file = "/var/lib/acme/ftp.uninsane.org/full.pem";
        certificate_key_file = "/var/lib/acme/ftp.uninsane.org/key.pem";

        banner = ''
          Welcome, friends, to Colin's FTP server! Also available via NFS on the same host, but LAN-only.

          Read-only access (LAN-restricted):
          Username: "anonymous"
          Password: "anonymous"

          CONFIGURE YOUR CLIENT FOR "PASSIVE" MODE, e.g. `ftp --passive ftp.uninsane.org`.
          Please let me know if anything's broken or not as it should be. Otherwise, browse and transfer freely :)
        '';

      };
      data_provider = {
        driver = "memory";
        external_auth_hook = "${sftpgo_external_auth_hook}/bin/sftpgo_external_auth_hook";
        # track_quota:
        # - 0: disable quota tracking
        # - 1: quota is updated on every upload/delete, even if user has no quota restriction
        # - 2: quota is updated on every upload/delete, but only if user/folder has a quota restriction  (default, i think)
        # track_quota = 2;
      };
    };
  };

  users.users.sftpgo.extraGroups = [
    "export"
    "media"
    "nginx"  # to access certs
  ];

  systemd.services.sftpgo = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ReadWritePaths = [ "/var/export" ];

      Restart = "always";
      RestartSec = "20s";
      UMask = lib.mkForce "0002";
    };
  };
}
