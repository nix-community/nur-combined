{ lib, pkgs, config, ... }:
let 
  cfg = config.services.scheduled-rsync;
  generateRsyncScript = name: {from, to, exclude-from, dry-run, rsh}: pkgs.writeScriptBin "rsyncScript.sh" ''
    #!${pkgs.bash}/bin/bash
    export PATH=${pkgs.lib.makeBinPath [ pkgs.rsync pkgs.openssh ]}:$PATH
    echo $PATH

    rsync ${if dry-run then "--dry-run" else ""} ${if builtins.stringLength rsh > 0 then "-e "+rsh else ""} \
    --archive \
    --one-file-system \
    --exclude-from=${generateExcludeFrom exclude-from} \
    ${from} \
    ${to}
  '';
  generateExcludeFrom = str: pkgs.writeTextFile {
    name = "ignore.txt";
    text = str;
  };
  generateCron = name: {Description, OnCalendar, from, to, rsh ? "", exclude-from ? "", dry-run ? false}: { ${name} = {
    ExecStart   = "${generateRsyncScript name {inherit from to exclude-from dry-run rsh;}}/bin/rsyncScript.sh";
    Description = Description;
    OnCalendar  = OnCalendar;
  }; };
  crons = lib.mapAttrsToList generateCron cfg.dirs;
in
{
  options.services.scheduled-rsync = {
    dirs = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      example = ''
      {
        backupHomeDir = {
          Description = "Backup home dir";
          OnCalendar="Wed *-*-* 03:00:00";
          from = "${config.home.homeDirectory}/"; #<- remember to postfix / if ur gonna use exclude-from like below
          to = "/mnt/bigdisk/backup/home2021";
          exclude-from = \'\'
            /.nuget
            /.npm
            /.minikube
            /.stack
            /tmp
            /go
            /work
            /database
            /.cache
            /Dropbox
            /.dropbox-hm
            /coding/kubernix
          \'\';
        };
      }
      '';
      description = ''
        Simplify scheduling backups with rsync.
      '';
    };
  };
  config = lib.mkIf (builtins.length crons > 0){
    services.systemd-cron.crons = (lib.mkMerge crons);
  };
}
