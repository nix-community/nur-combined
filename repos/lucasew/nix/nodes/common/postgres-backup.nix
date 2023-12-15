{ config, pkgs, lib, ...}:

let
  cfg = config.services.postgresqlBackup;

  servicesToMonkeyPatch = if cfg.backupAll then [ "postgresqlBackup" ] else (map (item: "postgresqlBackup-${item}") cfg.databases);
in
{
  config = lib.mkIf cfg.enable {
  # assertions = [
  #   {
  #     assertion = false;
  #     message = builtins.toJSON servicesToMonkeyPatch;
  #   }
  # ];
    systemd.services = lib.listToAttrs (map (item: {
      name = item;
      value = {
        path = with pkgs; [ rclone ];
        script = lib.mkAfter ''
          function _mail() {
            if [ -x /run/wrappers/bin/sendmail ]; then
              subject="${item}"
              if [ $# -gt 0 ]; then
                subject="$subject: $*"
              fi
              cat <(printf "Subject: %s\n" "$subject") - | /run/wrappers/bin/sendmail
            fi
          }

          _mail Backup local finalizado!
          if [ ! -f ~/rclone.conf ]; then
            echo Credenciais do rclone não encontradas. Crie um remote postgres_backup em um rclone.conf e coloque em ~/rclone.conf! | _mail "Configuração do rclone não encontrada"
          fi
          rclone copy "${cfg.location}" postgres_backup: -v --config ~/rclone.conf | _mail Progresso do rclone
          _mail Backup remoto finalizado!

        '';
      };
    }) servicesToMonkeyPatch);
  };
}
