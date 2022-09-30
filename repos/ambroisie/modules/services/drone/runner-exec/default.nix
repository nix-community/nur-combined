{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.drone;
  hasRunner = (name: builtins.elem name cfg.runners);
  execPkg = pkgs.drone-runner-exec;
in
{
  config = lib.mkIf (cfg.enable && hasRunner "exec") {
    systemd.services.drone-runner-exec = {
      wantedBy = [ "multi-user.target" ];
      # might break deployment
      restartIfChanged = false;
      confinement.enable = true;
      confinement.packages = with pkgs; [
        git
        gnutar
        bash
        nix
        gzip
      ];
      path = with pkgs; [
        git
        gnutar
        bash
        nix
        gzip
      ];
      serviceConfig = {
        Environment = [
          "DRONE_SERVER_HOST=drone.${config.networking.domain}"
          "DRONE_SERVER_PROTO=https"
          "DRONE_RUNNER_CAPACITY=10"
          "CLIENT_DRONE_RPC_HOST=127.0.0.1:${toString cfg.port}"
          "NIX_REMOTE=daemon"
          "PAGER=cat"
        ];
        BindPaths = [
          "/nix/var/nix/daemon-socket/socket"
          "/run/nscd/socket"
        ];
        BindReadOnlyPaths = [
          "/etc/resolv.conf:/etc/resolv.conf"
          "/etc/resolvconf.conf:/etc/resolvconf.conf"
          "/etc/passwd:/etc/passwd"
          "/etc/group:/etc/group"
          "/nix/var/nix/profiles/system/etc/nix:/etc/nix"
          "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-certificates.crt"
          "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/"
        ];
        EnvironmentFile = [
          cfg.sharedSecretFile
        ];
        ExecStart = "${execPkg}/bin/drone-runner-exec";
        User = "drone-runner-exec";
        Group = "drone-runner-exec";
      };
    };

    users.users.drone-runner-exec = {
      isSystemUser = true;
      group = "drone-runner-exec";
    };
    users.groups.drone-runner-exec = { };
  };
}
