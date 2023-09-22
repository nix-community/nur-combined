{ lib, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.sshfs ];

  systemd.user.services = {
    "sshfs-TMP2" = {
      path = with pkgs; [ sshfs ];
      script = ''
        sshfs $(whoami)@riverwood:/home/$(whoami)/TMP2 /home/$(whoami)/TMP2 -f
      '';
      restartIfChanged = true;
    };

    "sshfs-WORKSPACE" = {
      path = with pkgs; [ sshfs ];
      script = ''
        sshfs $(whoami)@riverwood:/home/$(whoami)/WORKSPACE /home/$(whoami)/WORKSPACE -f
      '';
      restartIfChanged = true;
    };
  };
}
