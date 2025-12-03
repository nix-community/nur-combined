{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sane-private-unlock-remote;
in
{
  sane.programs."sane-private-unlock-remote" = {
    packageUnwrapped = pkgs.sane-scripts.private-unlock-remote;
    sandbox.net = "all";
    sandbox.extraHomePaths = [
      ".config/sops"
      "knowledge/secrets"
    ];
    sandbox.whitelistSsh = true;
    suggestedPrograms = [
      "sane-scripts.secrets-dump"
      "ssh"
    ];

    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.interval = mkOption {
          type = types.int;
          default = 60;
          description = ''
            how frequently to check in on the remote hosts (in seconds)
          '';
        };
        options.hosts = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            list of hosts which should be remotely unlocked automatically
          '';
        };
      };
    };

    services.sane-private-unlock-remote = {
      description = "private-unlock-remote: unlock the 'private' store of trusted remote machines";
      partOf = lib.mkIf (cfg.config.hosts != []) [ "default" ];
      command = pkgs.writeShellScript "private-unlock-remote-loop" ''
        hosts=(${lib.escapeShellArgs cfg.config.hosts})
        interval=${builtins.toString cfg.config.interval}
        while true; do
          for host in "''${hosts[@]}"; do
            echo "attempting to unlock $host"
            sane-private-unlock-remote "$host"
          done
          sleep "$interval"
        done
      '';
    };
  };
}
