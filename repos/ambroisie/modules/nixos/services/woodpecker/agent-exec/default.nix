{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.woodpecker;

  hasRunner = (name: builtins.elem name cfg.runners);
in
{
  config = lib.mkIf (cfg.enable && hasRunner "exec") {
    services.woodpecker-agents = {
      agents.exec = {
        enable = true;

        environment = {
          WOODPECKER_SERVER = "localhost:${toString cfg.rpcPort}";
          WOODPECKER_MAX_WORKFLOWS = "10";
          WOODPECKER_BACKEND = "local";
          WOODPECKER_FILTER_LABELS = "type=exec";
          WOODPECKER_HEALTHCHECK = "false";

          NIX_REMOTE = "daemon";
          PAGER = "cat";
        };

        path = with pkgs; [
          woodpecker-plugin-git
          bash
          coreutils
          git
          git-lfs
          gnutar
          gzip
          nix
        ];

        environmentFile = [ cfg.sharedSecretFile ];
      };
    };

    # Adjust runner service for nix usage
    systemd.services.woodpecker-agent-exec = {
      # Might break deployment
      restartIfChanged = false;

      serviceConfig = {
        # Same option as upstream, without @setuid
        SystemCallFilter = lib.mkForce "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @swap";
        # NodeJS requires RWX memory...
        MemoryDenyWriteExecute = lib.mkForce false;

        BindPaths = [
          "/nix/var/nix/daemon-socket/socket"
          "/run/nscd/socket"
        ];
        BindReadOnlyPaths = [
          "/etc/passwd:/etc/passwd"
          "/etc/group:/etc/group"
          "/etc/nix:/etc/nix"
          "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/"
        ];
      };
    };
  };
}
