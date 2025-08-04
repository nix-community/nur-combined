{
  reIf,
  lib,
  pkgs,
  ...
}:
reIf {

  services.prometheus.exporters.postgres = {
    enable = true;
    listenAddress = "[::]";
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17_jit;
    extensions = ps: [
      ps.pgvector
      ps.vectorchord
    ];
    enableTCPIP = true;
    settings = {
      allow_alter_system = false;
      port = 5432;

      # https://pgtune.leopard.in.ua/
      # DB Version: 17
      # OS Type: linux
      # DB Type: mixed
      # Total Memory (RAM): 32 GB
      # CPUs num: 8
      # Data Storage: ssd

      wal_buffers = "16MB";
      work_mem = "38836kB";
      huge_pages = "try";
      max_worker_processes = 8;
      max_parallel_workers_per_gather = 4;
      max_parallel_workers = 8;
      max_parallel_maintenance_workers = 4;
      max_connections = 100;
      shared_buffers = "8GB";
      effective_cache_size = "24GB";
      maintenance_work_mem = "2GB";
      checkpoint_completion_target = 0.9;
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      min_wal_size = "2GB";
      max_wal_size = "8GB";

      shared_preload_libraries = [
        "vchord.so"
      ];

      search_path = "\"$user\", public, vectors";
    };

    authentication = lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust

      #type database DBuser origin-address auth-method
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust

      host all       all     10.88.0.0/16    scram-sha-256
      host all       all     192.168.0.0/16    scram-sha-256
    '';

  };
}
