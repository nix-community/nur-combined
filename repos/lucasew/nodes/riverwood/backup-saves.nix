{config, pkgs, ...}:
{
  # TODO: abstract stuff to options
  systemd.user.services."backup-saves" = {
    enable = true;
    description = "Backup some paths to a Git repo";
    path = with pkgs; [ git openssh libnotify ];
    script = ''
      set -eu
      SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent
      ${pkgs.python3Packages.python.interpreter} ${../../bin/backup-savegames}
      
    '';
    startAt = "*-*-* *:00:00"; # hourly, i guess
    environment = {
      STATE_BACKUP_DIR = "~/WORKSPACE/ANNEX/SAVES";
      SAVEGAMES_FOLDERS = builtins.toJSON (let
        listSeqRecur = accum: val: if val == null then accum else (listSeqRecur (accum ++ [val]));
        listSeq = listSeqRecur [];
        numSeq = from: to: if from >= to then [] else [from] ++ (numSeq (from + 1) to);
      in {
        "bully" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/Bully Scholarship Edition/" null;
        "deadspace" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/Electronic Arts/Dead Space/" null;
        "ets2" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/Euro Truck Simulator 2/profiles/" "/run/media/lucasew/Dados/DADOS/Lucas/Documents/Euro Truck Simulator 2/config.cfg" null;
        "flatout2" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/Flatout2/" null;
        "fs13" = map (num: "/run/media/lucasew/Dados/DADOS/Lucas/Documents/My Games/FarmingSimulator2013/savegame${toString num}") (numSeq 1 30);
        "fs19" = map (num: "/run/media/lucasew/Dados/DADOS/Lucas/Documents/My Games/FarmingSimulator2019/savegame${toString num}") (numSeq 1 30);
        "gtasa" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/GTA San Andreas User Files/" null;
        "gtav" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/AppData/Roaming/Goldberg SocialClub Emu Saves/GTA V/" null;
        "gtavc" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/GTA Vice City User Files/" null;
        "haulin" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/18 WoS Haulin/save/" null;
        "nfsmw" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/NFS Most Wanted/" null;
        "nfsu2" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/AppData/Local/NFS Underground 2/" null;
        "pttm" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/18 WoS Pedal to the Metal/" null;
        "rimworld" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/AppData/LocalLow/Ludeon Studios" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/Rimworld/" null;
        "scrap_mechanic" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/AppData/Roaming/Axolot Games/Scrap Mechanic/" null;
        "skyrim" = listSeq "~/.config/The_Elder_Scrolls_V_Skyrim_Special_Edition_AppImage_01/users/lucasew/Documents/My Games/Skyrim Special Edition" null;
        "stk" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/config-0.10/config.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/config-0.10/highscore.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/config-0.10/input.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/config-0.10/players.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/config-0.10/server_config.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/addons/addons.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/addons/addons_installed.xml" "/run/media/lucasew/Dados/DADOS/Lucas/AppData/supertuxkart/addons/online_news.xml" null;
        "watchdogs2" = listSeq "/run/media/lucasew/Dados/DADOS/Lucas/Documents/WatchDogs2/CPY_SAVES/" null;
      });
    };
  };
}
