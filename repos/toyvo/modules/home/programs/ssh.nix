{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    services.ssh-agent.enable = true;

    programs = {
      ssh = {
        enableDefaultConfig = false;
        # Router admin SSH moved off 22; port 22 on the router is git-over-SSH
        # (relayed to the nas / forgejo)
        settings."router router.internal router.diekvoss.net 10.1.0.1".Port = "2222";
        settings."*" = {
          ForwardAgent = "no";
          AddKeysToAgent = "no";
          Compression = "no";
          ServerAliveInterval = "0";
          ServerAliveCountMax = "3";
          HashKnownHosts = "no";
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      };
    };
  };
}
