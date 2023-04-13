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

        package = pkgs.ambroisie.woodpecker-agent;

        environment = {
          WOODPECKER_SERVER = "localhost:${toString cfg.rpcPort}";
          WOODPECKER_MAX_WORKFLOWS = "10";
          WOODPECKER_BACKEND = "local";
          WOODPECKER_FILTER_LABELS = "type=exec";
          WOODPECKER_HEALTHCHECK = "false";

          NIX_REMOTE = "daemon";
          PAGER = "cat";
        };

        environmentFile = [ cfg.sharedSecretFile ];
      };
    };

    # Adjust runner service for nix usage
    systemd.services.woodpecker-agent-exec = {
      # Might break deployment
      restartIfChanged = false;

      path = with pkgs; [
        ambroisie.woodpecker-plugin-git
        bash
        coreutils
        git
        git-lfs
        gnutar
        gzip
        nix
      ];

      serviceConfig = {
        # Same option as upstream, without @setuid
        SystemCallFilter = lib.mkForce "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @swap";

        BindPaths = [
          "/nix/var/nix/daemon-socket/socket"
          "/run/nscd/socket"
        ];
        BindReadOnlyPaths = [
          "/etc/passwd:/etc/passwd"
          "/etc/group:/etc/group"
          "/nix/var/nix/profiles/system/etc/nix:/etc/nix"
          "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/"
        ];
      };
    };
  };
}
