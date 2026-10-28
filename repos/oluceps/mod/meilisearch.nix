{
  flake.modules.nixos.meilisearch =
    {
      config,
      lib,
      ...
    }:
    {
      vaultix.secrets.meilisearch = {
        owner = "meilisearch";
        mode = "400";
      };
      systemd.services.meilisearch.environment.MEILI_NO_ANALYTICS = lib.mkForce "true";
      realm.workloads.meilisearch = {
        isolation.runtimePaths = [ "/run/meilisearch" ];
        ingress.http = {
          port = 17700;
          backend = {
            kind = "private-tcp";
            port = 7700;
          };
          service = "meilisearch";
          allow.identities = config.realm.caddy.allowedIDs.meilisearch ++ [
            "spiffe://nyaw.xyz/service/misskey"
          ];
        };
      };
      services.meilisearch = {
        enable = true;
        listenAddress = "127.0.0.1";
        # settings.env = "production";
        settings.env = "development";
        # Unset, these default to "2/3 of available memory" (~21G here) and
        # "half of the cores". Every write batch on the 1.37M-document misskey
        # notes index already needs ~1.3G of anonymous memory; a settings
        # change or a bulk reindex must not be allowed to take 20G.
        settings.max_indexing_memory = "1GiB";
        settings.max_indexing_threads = 2;
        masterKeyFile = config.vaultix.secrets.meilisearch.path;
      };
      systemd.services.meilisearch.serviceConfig = {
        # Backstop in case the indexer still runs away. LMDB pages are clean
        # file cache, so the kernel reclaims them instead of OOM-killing the
        # service; MemoryHigh throttles before MemoryMax.
        MemoryHigh = "2500M";
        MemoryMax = "3G";
      };
    };
}
