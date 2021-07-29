{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.postgresql;
in
{
  options.my.services.postgresql = with lib; {
    enable = my.mkDisableOption "postgres configuration";

    # Transient option to be enabled for migrations
    upgradeScript = mkEnableOption "postgres upgrade script";
  };

  config = lib.mkMerge [
    # Let other services enable postgres when they need it
    (lib.mkIf cfg.enable {
      services.postgresql = {
        package = pkgs.postgresql_13;
      };
    })

    # Taken from the manual
    (lib.mkIf cfg.upgradeScript {
      containers.temp-pg.config.services.postgresql = {
        enable = true;
        package = pkgs.postgresql_13;
      };

      environment.systemPackages =
        let
          newpg = config.containers.temp-pg.config.services.postgresql;
        in
        [
          (pkgs.writeScriptBin "upgrade-pg-cluster" ''
            #!/usr/bin/env bash

            set -x
            export OLDDATA="${config.services.postgresql.dataDir}"
            export NEWDATA="${newpg.dataDir}"
            export OLDBIN="${config.services.postgresql.package}/bin"
            export NEWBIN="${newpg.package}/bin"

            if [ "$OLDDATA" -ef "$NEWDATA" ]; then
              echo "Cannot migrate to same data directory" >&2
              exit 1
            fi

            install -d -m 0700 -o postgres -g postgres "$NEWDATA"
            cd "$NEWDATA"
            sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

            systemctl stop postgresql    # old one

            sudo -u postgres $NEWBIN/pg_upgrade \
              --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
              --old-bindir $OLDBIN --new-bindir $NEWBIN \
              "$@"
          '')
        ];
    })
  ];
}
