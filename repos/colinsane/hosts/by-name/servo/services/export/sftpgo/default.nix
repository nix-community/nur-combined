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
  external_auth_hook = pkgs.static-nix-shell.mkPython3 {
    pname = "external_auth_hook";
    srcRoot = ./.;
    pkgs = [ "python3.pkgs.passlib" ];
  };
  # Client initiates a FTP "control connection" on port 21.
  # - this handles the client -> server commands, and the server -> client status, but not the actual data
  # - file data, directory listings, etc need to be transferred on an ephemeral "data port".
  # - 50000-50100 is a common port range for this.
  #   50000 is used by soulseek.
  passiveStart = 50050;
  passiveEnd   = 50070;
in
{
  sane.ports.ports = {
    "21" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      description = "colin-FTP server";
    };
    "990" = {
      protocol = [ "tcp" ];
      visibleTo.doof = true;
      visibleTo.lan = true;
      description = "colin-FTPS server";
    };
  } // (sane-lib.mapToAttrs
    (port: {
      name = builtins.toString port;
      value = {
        protocol = [ "tcp" ];
        visibleTo.doof = true;
        visibleTo.lan = true;
        description = "colin-FTP server data port range";
      };
    })
    (lib.range passiveStart passiveEnd)
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

    package = pkgs.sftpgo.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        # fix for compatibility with kodi:
        # ftp LIST operation returns entries over-the-wire like:
        # - dgrwxrwxr-x 1 ftp ftp            9 Apr  9 15:05 Videos
        # however not all clients understand all mode bits (like that `g`, indicating SGID / group sticky bit).
        # instead, only send mode bits which are well-understood.
        # the full set of bits, from which i filter, is found here: <https://pkg.go.dev/io/fs#FileMode>
        ./safe_fileinfo.patch
      ];
    });

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
            # binding this means any wireguard client can connect
            address = "10.0.10.5";
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
          {
            # binding this means any LAN client can connect (also WAN traffic forwarded from the gateway)
            address = "10.78.79.51";
            port = 21;
            debug = true;
          }
          {
            # binding this means any LAN client can connect (also WAN traffic forwarded from the gateway)
            address = "10.78.79.51";
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
          {
            # binding this means any doof client can connect (TLS only)
            address = config.sane.netns.doof.veth.initns.ipv4;
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
          {
            # binding this means any LAN client can connect via `ftp.uninsane.org` (TLS only)
            address = config.sane.netns.doof.wg.address.ipv4;
            port = 990;
            debug = true;
            tls_mode = 2;  # 2 = "implicit FTPS": client negotiates TLS before any FTP command.
          }
        ];

        # active mode is susceptible to "bounce attacks", without much benefit over passive mode
        disable_active_mode = true;
        hash_support = true;
        passive_port_range = {
          start = passiveStart;
          end = passiveEnd;
        };

        certificate_file = "/var/lib/acme/ftp.uninsane.org/full.pem";
        certificate_key_file = "/var/lib/acme/ftp.uninsane.org/key.pem";

        banner = ''
          Welcome, friends, to Colin's FTP server! Also available via NFS on the same host, but LAN-only.

          Read-only access (LAN clients see everything; WAN clients can only see /pub):
          Username: "anonymous"
          Password: "anonymous"

          CONFIGURE YOUR CLIENT FOR "PASSIVE" MODE, e.g. `ftp --passive ftp.uninsane.org`.
          Please let me know if anything's broken or not as it should be. Otherwise, browse and transfer freely :)
        '';

      };
      data_provider = {
        driver = "memory";
        external_auth_hook = lib.getExe external_auth_hook;
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
    after = [ "network-online.target" ];  #< so that it reliably binds to all interfaces/netns's?
    wants = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [
      "/var/export/media"
      "/var/export/playground"
    ];
    serviceConfig.ReadWritePaths = [ "/var/export" ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "20s";
    serviceConfig.UMask = lib.mkForce "0002";
  };
}
