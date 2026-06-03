{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh.initContent = ''
        ! (echo "$SSH_AUTH_SOCK" | ${lib.getExe pkgs.ripgrep} ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      bash.initExtra = ''
        ! (echo "$SSH_AUTH_SOCK" | ${lib.getExe pkgs.ripgrep} ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      fish.interactiveShellInit = ''
        ! echo "$SSH_AUTH_SOCK" | ${lib.getExe pkgs.ripgrep} ssh-\[a-zA-Z0-9\]+\/agent\.\\d+\$ >/dev/null; and eval $(ssh-agent -c) >/dev/null
      '';
      nushell.configFile.text = ''
        if (echo $env.SSH_AUTH_SOCK | ${lib.getExe pkgs.ripgrep} ssh-[a-zA-Z0-9]+/agent\.\d+$) == "" {
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
