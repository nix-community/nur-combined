{ config, pkgs, lib, ...}:

let
  cfg = config.services.postgresqlBackup;

  servicesToMonkeyPatch = if cfg.backupAll then [ "postgresqlBackup" ] else (map (item: "postgresqlBackup-${item}") cfg.databases);
in
{
  config = lib.mkIf cfg.enable {
    systemd.services = lib.listToAttrs (map (item: {
      name = item;
      value = {
        path = with pkgs; [ rclone ];
        script = lib.mkAfter ''
          item="${item}"
          function _mail() {
            if [ -x /run/wrappers/bin/sendmail ]; then
              subject="$item"
              if [ $# -gt 0 ]; then
                subject="$subject: $*"
              fi
              cat <(printf "Subject: %s\n\n" "$subject") - | /run/wrappers/bin/sendmail
            fi
          }

          _mail Backup local finalizado!
          if [ ! -f ~/rclone.conf ]; then
            echo Credenciais do rclone não encontradas. Crie um remote postgres_backup em um rclone.conf e coloque em ~/rclone.conf! | _mail "Configuração do rclone não encontrada"
          else
            {
              set +f
              item_name="${"$"}{item##postgresqlBackup}"
              item_name="${"$"}{item_name##-}"

              for item in "${cfg.location}/"*"$item_name"*; do
                echo "[*] Copying '$item'..."
                rclone copy "$item" postgres_backup: -v --config ~/rclone.conf 2>&1
              done
              set -f
            } | _mail Backup remoto finalizado
          fi

        '';
      };
    }) servicesToMonkeyPatch);
  };
}
