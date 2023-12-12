# docs:
# - <https://github.com/drakkan/sftpgo>
# - config options: <https://github.com/drakkan/sftpgo/blob/main/docs/full-configuration.md>
# - config defaults: <https://github.com/drakkan/sftpgo/blob/main/sftpgo.json>
# - nixos options: <repo:nixos/nixpkgs:nixos/modules/services/web-apps/sftpgo.nix>
# - nixos example: <repo:nixos/nixpkgs:nixos/tests/sftpgo.nix>
#
# sftpgo is a FTP server that also supports WebDAV, SFTP, and web clients.
#
# TODO: change umask so sftpgo-created files default to 644.
# - it does indeed appear that the 600 is not something sftpgo is explicitly doing.


{ config, lib, pkgs, sane-lib, ... }:
let
  # user permissions:
  # - see <repo:drakkan/sftpgo:internal/dataprovider/user.go>
  # - "*" = grant all permissions
  # - read-only perms:
  #   - "list" = list files and directories
  #   - "download"
  # - rw perms:
  #   - "upload"
  #   - "overwrite" = allow uploads to replace existing files
  #   - "delete" = delete files and directories
  #     - "delete_files"
  #     - "delete_dirs"
  #   - "rename" = rename files and directories
  #     - "rename_files"
  #     - "rename_dirs"
  #   - "create_dirs"
  #   - "create_symlinks"
  #   - "chmod"
  #   - "chown"
  #   - "chtimes" = change atime/mtime (access and modification times)
  #
  # home_dir:
  # - it seems (empirically) that a user can't cd above their home directory.
  #   though i don't have a reference for that in the docs.
  authResponseSuccess = {
    status = 1;
    username = "anonymous";
    expiration_date = 0;
    home_dir = "/var/export";
    # uid/gid 0 means to inherit sftpgo uid.
    # - i.e. users can't read files which Linux user `sftpgo` can't read
    # - uploaded files belong to Linux user `sftpgo`
    # other uid/gid values aren't possible for localfs backend, unless i let sftpgo use `sudo`.
    uid = 0;
    gid = 0;
    # uid = 65534;
    # gid = 65534;
    max_sessions = 0;
    # quota_*: 0 means to not use SFTP's quota system
    quota_size = 0;
    quota_files = 0;
    permissions = {
      "/" = [ "list" "download" ];
      "/playground" = [
        # read-only:
        "list"
        "download"
        # write:
        "upload"
        "overwrite"
        "delete"
        "rename"
        "create_dirs"
        "create_symlinks"
        # intentionally omitted:
        # "chmod"
        # "chown"
        # "chtimes"
      ];
    };
    upload_bandwidth = 0;
    download_bandwidth = 0;
    filters = {
      allowed_ip = [];
      denied_ip = [];
    };
    public_keys = [];
    # other fields:
    # ? groups
    # ? virtual_folders
  };
  authResponseFail = {
    username = "";
  };
  authSuccessJson = pkgs.writeText "sftp-auth-success.json" (builtins.toJSON authResponseSuccess);
  authFailJson = pkgs.writeText "sftp-auth-fail.json" (builtins.toJSON authResponseFail);
  unwrappedAuthProgram = pkgs.static-nix-shell.mkBash {
    pname = "sftpgo_external_auth_hook";
    src = ./.;
    pkgs = [ "coreutils" ];
  };
  authProgram = pkgs.writeShellScript "sftpgo-auth-hook" ''
    ${unwrappedAuthProgram}/bin/sftpgo_external_auth_hook ${authFailJson} ${authSuccessJson}
  '';
in
{
  # Client initiates a FTP "control connection" on port 21.
  # - this handles the client -> server commands, and the server -> client status, but not the actual data
  # - file data, directory listings, etc need to be transferred on an ephemeral "data port".
  # - 50000-50100 is a common port range for this.
  sane.ports.ports = {
    "21" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      description = "colin-FTP server";
    };
  } // (sane-lib.mapToAttrs
    (port: {
      name = builtins.toString port;
      value = {
        protocol = [ "tcp" ];
        visibleTo.lan = true;
        description = "colin-FTP server data port range";
      };
    })
    (lib.range 50000 50100)
  );

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
            # binding this means any LAN client can connect
            address = "10.78.79.51";
            port = 21;
            debug = true;
          }
        ];

        # active mode is susceptible to "bounce attacks", without much benefit over passive mode
        disable_active_mode = true;
        hash_support = true;
        passive_port_range = {
          start = 50000;
          end = 50100;
        };

        banner = ''
          Welcome, friends, to Colin's read-only FTP server! Also available via NFS on the same host.
          Username: "anonymous"
          Password: "anonymous"
          CONFIGURE YOUR CLIENT FOR "PASSIVE" mode, e.g. `ftp --passive uninsane.org`
          Please let me know if anything's broken or not as it should be. Otherwise, browse and DL freely :)
        '';

      };
      data_provider = {
        driver = "memory";
        external_auth_hook = "${authProgram}";
        # track_quota:
        # - 0: disable quota tracking
        # - 1: quota is updated on every upload/delete, even if user has no quota restriction
        # - 2: quota is updated on every upload/delete, but only if user/folder has a quota restriction  (default, i think)
        # track_quota = 2;
      };
    };
  };

  users.users.sftpgo.extraGroups = [ "export" ];

  systemd.services.sftpgo = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ReadOnlyPaths = [ "/var/export" ];
      ReadWritePaths = [ "/var/export/playground" ];

      Restart = "always";
      RestartSec = "20s";
    };
  };
}
