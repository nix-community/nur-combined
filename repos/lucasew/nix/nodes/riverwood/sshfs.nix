{ lib, pkgs, ... }:

let
  sshfsArgs = lib.escapeShellArgs [
    "-f"
    "-o"
    "reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,allow_other,default_permissions,cache=no"
  ];
  sshAgentSnippet = ../../../config/.bashrc.d.tmpl/30-integrations-ssh-agent.sh;
  mounts = [
    "TMP2"
    "WORKSPACE"
  ];
  mkMount = name: {
    path = [ pkgs.sshfs ];
    script = ''
      . ${sshAgentSnippet}
      exec sshfs $(whoami)@whiterun:/home/$(whoami)/${name} /home/$(whoami)/${name} ${sshfsArgs}
    '';
    restartIfChanged = true;
  };
in
{
  environment.systemPackages = [ pkgs.sshfs ];

  systemd.user.services = lib.listToAttrs (
    map (name: {
      name = "sshfs-${name}";
      value = mkMount name;
    }) mounts
  );
}
