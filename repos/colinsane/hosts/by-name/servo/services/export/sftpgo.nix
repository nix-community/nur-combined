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

    package = lib.warnIf (lib.versionOlder "2.5.6" pkgs.sftpgo.version) "sftpgo update: safe to use nixpkgs' sftpgo but keep my own `patches`" pkgs.buildGoModule {
      inherit (pkgs.sftpgo) name ldflags nativeBuildInputs doCheck subPackages postInstall passthru meta;
      version = "2.5.6-unstable-2024-04-18";
      src = pkgs.fetchFromGitHub {
        # need to use > 2.5.6 for sftpgo_safe_fileinfo.patch to apply
        owner = "drakkan";
        repo = "sftpgo";
        rev = "950cf67e4c03a12c7e439802cabbb0b42d4ee5f5";
        hash = "sha256-UfiFd9NK3DdZ1J+FPGZrM7r2mo9xlKi0dsSlLEinYXM=";
      };
      vendorHash = "sha256-n1/9A2em3BCtFX+132ualh4NQwkwewMxYIMOphJEamg=";
      patches = (pkgs.sftpgo.patches or []) ++ [
        # fix for compatibility with kodi:
        # ftp LIST operation returns entries over-the-wire like:
        # - dgrwxrwxr-x 1 ftp ftp            9 Apr  9 15:05 Videos
        # however not all clients understand all mode bits (like that `g`, indicating SGID / group sticky bit).
        # instead, only send mode bits which are well-understood.
        # the full set of bits, from which i filter, is found here: <https://pkg.go.dev/io/fs#FileMode>
        ./sftpgo_safe_fileinfo.patch
      ];
    };

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
