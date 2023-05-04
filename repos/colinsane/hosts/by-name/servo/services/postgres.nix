{ ... }:

{
  sane.persist.sys.plaintext = [
    # TODO: mode?
    { user = "postgres"; group = "postgres"; directory = "/var/lib/postgresql"; }
  ];
  services.postgresql.enable = true;
  # services.postgresql.dataDir = "/opt/postgresql/13";
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
