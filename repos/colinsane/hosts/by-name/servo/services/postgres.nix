{ pkgs, ... }:

{
  sane.persist.sys.plaintext = [
    # TODO: mode?
    { user = "postgres"; group = "postgres"; path = "/var/lib/postgresql"; }
  ];
  services.postgresql.enable = true;

  # HOW TO UPDATE:
  # postgres version updates are manual and require intervention.
  # - `sane-stop-all-servo`
  # - `systemctl start postgresql`
  # - as `sudo su postgres`:
  #   - `cd /var/log/postgresql`
  #   - `pg_dumpall > state.sql`
  #   - `echo placeholder > <new_version>`  # to prevent state from being created earlier than we want
  # - then, atomically:
  #   - update the `services.postgresql.package` here
  #   - `dataDir` is atomically updated to match package; don't touch
  #   - `nixos-rebuild --flake . switch ; sane-stop-all-servo`
  # - `sudo rm -rf /var/lib/postgresql/<new_version>`
  # - `systemctl start postgresql`
  # - as `sudo su postgres`:
  #   - `cd /var/lib/postgreql`
  #   - `psql -f state.sql`
  # - restart dependent services (maybe test one at a time)

  services.postgresql.package = pkgs.postgresql_15;


  # XXX colin: for a proper deploy, we'd want to include something for Pleroma here too.
  # services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
  #   CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '<password goes here>';
  #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
  #     TEMPLATE template0
  #     ENCODING = "UTF8"
  #     LC_COLLATE = "C"
  #     LC_CTYPE = "C";
  # '';

  # TODO: perf tuning
  # - for recommended values see: <https://pgtune.leopard.in.ua/>
  # - for official docs (sparse), see: <https://www.postgresql.org/docs/11/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE>
  # services.postgresql.settings = { ... }

  # daily backups to /var/backup
  services.postgresqlBackup.enable = true;

  # common admin operations:
  #   sudo systemctl start postgresql
  #   sudo -u postgres psql
  #   > \l   # lists all databases
  #   > \du  # lists all roles
  #   > \c pleroma  # connects to database by name
  #   > \d   # shows all tables
  #   > \q   # exits psql
  # dump/restore (-F t = tar):
  #   sudo -u postgres pg_dump -F t pleroma > /backup/pleroma-db.tar
  #   sudo -u postgres -g postgres pg_restore -d pleroma /backup/pleroma-db.tar
}
