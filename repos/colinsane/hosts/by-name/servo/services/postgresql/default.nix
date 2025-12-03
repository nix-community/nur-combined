{ lib, pkgs, ... }:

let
  GiB = n: MiB 1024*n;
  MiB = n: KiB 1024*n;
  KiB = n: 1024*n;
in
{
  sane.persist.sys.byStore.private = [
    { user = "postgres"; group = "postgres"; mode = "0750"; path = "/var/lib/postgresql"; method = "bind"; }
    { user = "postgres"; group = "postgres"; mode = "0750"; path = "/var/backup/postgresql"; method = "bind"; }
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
  #     (for a compressed dump: `gunzip --stdout state.sql.gz | psql`)
  # - restart dependent services (maybe test one at a time)

  services.postgresql.package = pkgs.postgresql_16;


  # XXX colin: for a proper deploy, we'd want to include something for Pleroma here too.
  # services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
  #   CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '<password goes here>';
  #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
  #     TEMPLATE template0
  #     ENCODING = "UTF8"
  #     LC_COLLATE = "C"
  #     LC_CTYPE = "C";
  # '';

  services.postgresql.settings = {
    # perf tuning
    # - for recommended values see: <https://pgtune.leopard.in.ua/>
    # - for official docs (sparse), see: <https://www.postgresql.org/docs/11/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE>
    # DB Version: 16
    # OS Type: linux
    # DB Type: web
    # vvv artificially constrained because the server's resources are shared across maaany services
    # Total Memory (RAM): 12 GB
    # CPUs num: 12
    # Data Storage: ssd
    max_connections = 200;
    shared_buffers = "3GB";
    effective_cache_size = "9GB";
    maintenance_work_mem = "768MB";
    checkpoint_completion_target = 0.9;
    wal_buffers = "16MB";
    default_statistics_target = 100;
    random_page_cost = 1.1;
    effective_io_concurrency = 200;
    work_mem = "3932kB";
    min_wal_size = "1GB";
    max_wal_size = "4GB";
    max_worker_processes = 12;
    max_parallel_workers_per_gather = 4;
    max_parallel_workers = 12;
    max_parallel_maintenance_workers = 4;

    # DEBUG OPTIONS:
    log_min_messages = "DEBUG1";
  };

  # regulate the restarts, so that systemd never disables it
  systemd.services.postgresql.serviceConfig.Restart = lib.mkForce "on-failure";
  systemd.services.postgresql.serviceConfig.RestartSec = 2;
  systemd.services.postgresql.serviceConfig.RestartMaxDelaySec = 10;
  systemd.services.postgresql.serviceConfig.RestartSteps = 4;
  systemd.services.postgresql.serviceConfig.StartLimitBurst = 120;
  # systemd.services.postgresql.serviceConfig.TimeoutStartSec = "14400s";  #< 14400 = 4 hours; recoveries are long

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
