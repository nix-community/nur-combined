{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.ssh;
  userKnownHostsFile = builtins.toFile "known_hosts" (concatStringsSep "\n" cfg.knownHosts);
in {
  options.programs.ssh = {
    strictHostKeyChecking = mkOption {
      type = types.enum [ "yes" "ask" "accept-new" "no" ]; # off == no?
      default = "ask";
      description = "Decide how keys are automatically added to known_hosts";
    };
    knownHosts = mkOption {
      type = types.listOf types.str;
      description = "SSH host keys to allow connections to";
      default = [];
    };
  };

  config.programs.ssh = {
    extraOptionOverrides.StrictHostKeyChecking = cfg.strictHostKeyChecking;
    userKnownHostsFile = mkIf (length cfg.knownHosts > 0) (toString (
      optional (cfg.strictHostKeyChecking != "yes") "~/.ssh/known_hosts"
      ++ [ userKnownHostsFile ]
    ));
  };
}
