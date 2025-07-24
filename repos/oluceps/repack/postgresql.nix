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
    package = pkgs.postgresql_16_jit;
    enableTCPIP = true;
    settings = {
      port = 5432;
      max_connections = 100;
      shared_buffers = "8GB";
      effective_cache_size = "24GB";
      maintenance_work_mem = "2GB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "-1";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      work_mem = "64MB";
      min_wal_size = "2GB";
      max_wal_size = "8GB";
      max_worker_processes = 4;
      max_parallel_workers_per_gather = 2;
      max_parallel_workers = 4;
      max_parallel_maintenance_workers = 2;
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
