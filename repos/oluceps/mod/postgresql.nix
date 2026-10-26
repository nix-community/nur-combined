{
  flake.modules.nixos.postgresql =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      realm.workloads.postgresql = {
        user = "postgres";
        group = "postgres";
        isolation.runtimePaths = [ "/run/postgresql" ];
        ingress = {
          # telegram-search = {
          #   port = 15436;
          #   target = "unix:/run/postgresql/.s.PGSQL.5432";
          #   service = "postgresql-telegram-search";
          #   backendUser = "realm-pg-telegram-search";
          #   allowedIDs = [ "spiffe://nyaw.xyz/service/telegram-search" ];
          # };
          autopeer = {
            port = 15438;
            backend = {
              kind = "unix";
              path = "/run/postgresql/.s.PGSQL.5432";
              peerUser = "realm-pg-autopeer";
            };
            service = "postgresql-autopeer";
            allow.identities = [ "spiffe://nyaw.xyz/service/autopeer" ];
          };
          artex = {
            port = 15439;
            backend = {
              kind = "unix";
              path = "/run/postgresql/.s.PGSQL.5432";
              peerUser = "realm-pg-artex";
            };
            service = "postgresql-artex";
            allow.workloads = [ "artex" ];
          };
        };
      };
      users.groups.realm-pg = { };
      users.users.realm-pg-autopeer = {
        isSystemUser = true;
        group = "realm-pg";
      };
      users.users.realm-pg-artex = {
        isSystemUser = true;
        group = "realm-pg";
      };

      realm.observability.endpoints.postgres.port = config.services.prometheus.exporters.postgres.port;
      services.prometheus.exporters.postgres = {
        enable = true;
        listenAddress = "127.0.0.1";
        runAsLocalSuperUser = true;
      };
      systemd.services.postgresql = {
        # PostgreSQL reads these file paths only at startup.
        restartTriggers = [
          config.services.postgresql.settings.hba_file
          config.services.postgresql.settings.ident_file
        ];
        serviceConfig = {
          ReadWritePaths = [ "/pool0/relation" ];
          # Socket consumers bind-mount this directory into private /run trees.
          # Keep its inode across stops, restarts, and automatic recovery.
          RuntimeDirectoryPreserve = "yes";
        };
      };
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17_jit;
        extensions = ps: [
          ps.pgvector
          ps.vectorchord
        ];
        enableTCPIP = false;
        settings = {
          listen_addresses = lib.mkForce "";
          allow_alter_system = false;
          port = 5432;
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
          shared_preload_libraries = "vchord.so,pg_stat_statements";
          "pg_stat_statements.track" = "top";
          search_path = "\"$user\", public, vectors";
        };

        # map_name connect_unix_user db_user
        identMap = ''
          local-vaultwarden vaultwarden vault
          local-seaweedfs seaweedfs seaweed
          realm-autopeer realm-pg-autopeer dn42
          realm-artex realm-pg-artex artex
        '';
        # type db db_user auth_type map
        authentication = lib.mkForce ''
          local vaultwarden vault peer map=local-vaultwarden
          local seaweedfs seaweed peer map=local-seaweedfs
          local dn42abhoth,dn42nodens,dn42yidhra dn42 peer map=realm-autopeer
          local artex artex peer map=realm-artex
          local all all peer
        '';
      };
    };
}
