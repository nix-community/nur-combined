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
    programs = {
      zsh.initContent = ''
        ! (echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      bash.initExtra = ''
        ! (echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      fish.interactiveShellInit = ''
        ! echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+\$ >/dev/null; and eval $(ssh-agent -c) >/dev/null
      '';
      nushell.configFile.text = ''
        if (echo $env.SSH_AUTH_SOCK | rg ssh-[a-zA-Z0-9]+/agent\.\d+$) == "" {
          ^ssh-agent -c
              | lines
              | first 2
              | parse "setenv {name} {value};"
              | transpose -r
              | into record
              | load-env
        }
      '';
      ssh = {
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };
  };
}
