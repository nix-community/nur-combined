# docs:
# - <https://github.com/drakkan/sftpgo>
# - config options: <https://github.com/drakkan/sftpgo/blob/main/docs/full-configuration.md>
# - config defaults: <https://github.com/drakkan/sftpgo/blob/main/sftpgo.json>
# - nixos options: <repo:nixos/nixpkgs:nixos/modules/services/web-apps/sftpgo.nix>
#
# sftpgo is a FTP server that also supports WebDAV, SFTP, and web clients.


{ lib, pkgs, sane-lib, ... }:
let
  authProgram = pkgs.static-nix-shell.mkBash {
    pname = "sftpgo_external_auth_hook";
    src = ./.;
  };
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
    settings = {
      ftpd = {
        bindings = [{
          address = "10.0.10.5";
          port = 21;
          debug = true;
        }];

        # active mode is susceptible to "bounce attacks", without much benefit over passive mode
        disable_active_mode = true;
        hash_support = true;
        passive_port_range = {
          start = 50000;
          end = 50100;
        };

        banner = ''
          Welcome, friends, to Colin's read-only FTP server! Also available via NFS on the same host.
          Please let me know if anything's broken or not as it should be. Otherwise, browse and DL freely :)
        '';

      };
      data_provider = {
        driver = "memory";
        external_auth_hook = "${authProgram}/bin/sftpgo_external_auth_hook";
      };
    };
  };
}
