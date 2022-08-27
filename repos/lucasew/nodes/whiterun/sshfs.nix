{ lib, pkgs, ... }:
{
  systemd.user.services = {
    "sshfs-TMP2" = {
      path = with pkgs; [ sshfs ];
      script = ''
        sshfs $(whoami)@192.168.69.2:/home/$(whoami)/TMP2 /home/$(whoami)/TMP2 -f -C
      '';
      restartIfChanged = true;
    };
    "sshfs-WORKSPACE" = {
      path = with pkgs; [ sshfs ];
      script = ''
        sshfs $(whoami)@192.168.69.2:/home/$(whoami)/WORKSPACE /home/$(whoami)/WORKSPACE -f -C
      '';
      restartIfChanged = true;
    };
  };
}
