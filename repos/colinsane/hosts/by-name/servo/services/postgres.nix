{ pkgs, ... }:

let
  GiB = n: MiB 1024*n;
  MiB = n: KiB 1024*n;
  KiB = n: 1024*n;
in
{
  sane.persist.sys.byStore.plaintext = [
    # TODO: mode?
    { user = "postgres"; group = "postgres"; path = "/var/lib/postgresql"; method = "bind"; }
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

  # perf tuning
  # - for recommended values see: <https://pgtune.leopard.in.ua/>
  # - for official docs (sparse), see: <https://www.postgresql.org/docs/11/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE>
  services.postgresql.settings = {
    # DB Version: 15
    # OS Type: linux
    # DB Type: web
    # Total Memory (RAM): 32 GB
    # CPUs num: 12
    # Data Storage: ssd
    max_connections = 200;
    shared_buffers = "8GB";
    effective_cache_size = "24GB";
    maintenance_work_mem = "2GB";
    checkpoint_completion_target = 0.9;
    wal_buffers = "16MB";
    default_statistics_target = 100;
    random_page_cost = 1.1;
    effective_io_concurrency = 200;
    work_mem = "10485kB";
    min_wal_size = "1GB";
    max_wal_size = "4GB";
    max_worker_processes = 12;
    max_parallel_workers_per_gather = 4;
    max_parallel_workers = 12;
    max_parallel_maintenance_workers = 4;
  };

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
