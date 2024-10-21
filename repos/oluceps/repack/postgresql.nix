{
  reIf,
  lib,
  pkgs,
  ...
}:
reIf {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16_jit;
    enableTCPIP = true;
    settings = {
      port = 5432;
      max_connections = 100;
      shared_buffers = "2GB";
      effective_cache_size = "6GB";
      maintenance_work_mem = "512MB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      work_mem = "5242kB";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
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
      host  all      all     10.0.1.1/24   trust
      host  all      all     10.0.0.1/24   trust
      # ipv6
      host all       all     ::1/128        trust
    '';

  };
}
