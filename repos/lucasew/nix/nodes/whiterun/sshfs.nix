{ lib, pkgs, ... }:

let
  sshfsArgs = lib.escapeShellArgs [
    "-f"
    "-o"
    "reconnect,ServerAliveInterval=15,ServerAliveCountMax=3"
  ];
in

{
  environment.systemPackages = [ pkgs.sshfs ];

  systemd.user.services = {
    "sshfs-TMP2" = {
      path = with pkgs; [ sshfs ];
      script = ''
        exec sshfs $(whoami)@riverwood:/home/$(whoami)/TMP2 /home/$(whoami)/TMP2 ${sshfsArgs}
      '';
      restartIfChanged = true;
    };

    "sshfs-WORKSPACE" = {
      path = with pkgs; [ sshfs ];
      script = ''
        exec sshfs $(whoami)@riverwood:/home/$(whoami)/WORKSPACE /home/$(whoami)/WORKSPACE ${sshfsArgs}
      '';
      restartIfChanged = true;
    };
  };
}
