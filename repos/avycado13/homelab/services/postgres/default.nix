let
  mkService = import ../../lib/mkService.nix;
in
mkService {
  name = "postgres";
  description = "PostgreSQL database service";
  defaultPort = 5432;
  runtime = "nixos";
  nixosService = "postgresql";

  extraOptions =
    { lib, ... }:
    {
      databases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "mydatabase" ];
        description = "List of databases to ensure are created.";
      };

      otherUsers = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [ ];
        description = "List of additional database users to create.";
      };
    };

  extraConfig =
    cfg:
    { pkgs, lib, ... }:
    {
      homelab.services.postgres.nixos = {
        enableTCPIP = true;
        ensureDatabases = cfg.databases;
        settings.ssl = true;

        authentication = lib.mkOverride 10 ''
          # TYPE  DATABASE  USER  ADDRESS         METHOD
          local   all       all                  trust
          host  sameuser    all     127.0.0.1/32 scram-sha-256
          host  sameuser    all     ::1/128 scram-sha-256
        '';

        identMap = ''
          # ArbitraryMapName systemUser DBUser
             superuser_map      root      postgres
             superuser_map      postgres  postgres
             # Let other names login as themselves
             superuser_map      /^(.*)$   \1
        '';

        initialScript = pkgs.writeText "postgres-init.sql" "";

        ensureUsers = [
          {
            name = "avy";
            ensureDBOwnership = true;
          }
        ]
        ++ map (
          u:
          if builtins.isString u then
            {
              name = u;
              ensureDBOwnership = true;
            }
          else
            u
        ) cfg.otherUsers;
      };
    };
}
