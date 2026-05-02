# NixOS VM test for the LiteLLM proxy with a real PostgreSQL backend.
#
# This test is the regression test for NixOS/nixpkgs#432925: it asserts that
# litellm boots, runs `prisma generate`/`prisma migrate deploy` against the
# database, and serves /health/readiness once the schema is in place.
#
# Upstream nixpkgs ships a litellm test that only checks the no-DB path
# (services.litellm.enable = true; wait for port 8080). That test passes
# even though the DB-backed path is broken. This test exercises the broken
# path and confirms our prisma-engines wiring repairs it.

{
  lib,
  testers,
  fetchurl,
  litellm,
  prisma-engines,
  prisma_6,
  postgresql,
  curl,
  writeShellScript,
}:

let
  port = 4000;
  dbName = "litellm";
  dbUser = "litellm";
  dbPassword = "litellm";
  masterKey = "sk-vmtest-1234567890";
  databaseUrl = "postgresql://${dbUser}:${dbPassword}@localhost:5432/${dbName}";
  stateDir = "/var/lib/litellm";

  # LiteLLM imports `tiktoken.get_encoding("cl100k_base")` at module-import
  # time, which triggers a network download from openaipublic.blob.core.windows.net.
  # That kills the proxy on a hermetic VM with no internet. Pre-seed the
  # encoding into CUSTOM_TIKTOKEN_CACHE_DIR using the same trick upstream
  # nixpkgs uses in its litellm NixOS module.
  tiktokenEncodings = {
    cl100k_base = {
      url = "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken";
      hash = "sha256-Ijkht27pm96ZW3/3OFE+7xAPtR0YyTWXoRO8/+hlsqc=";
    };
  };

  seedTiktokenCacheScript = writeShellScript "litellm-seed-tiktoken-cache" ''
    set -eu
    mkdir -p "$CUSTOM_TIKTOKEN_CACHE_DIR"
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        _: encoding:
        let
          cacheKey = builtins.hashString "sha1" encoding.url;
          sourceFile = fetchurl { inherit (encoding) url hash; };
        in
        ''ln -sf ${sourceFile} "$CUSTOM_TIKTOKEN_CACHE_DIR/${cacheKey}"''
      ) tiktokenEncodings
    )}
  '';

  # Minimal config: define one mock-completion model so /v1/models works
  # without needing real upstream API credentials at test time.
  litellmConfig = builtins.toFile "litellm-config.yaml" ''
    model_list:
      - model_name: mock-gpt
        litellm_params:
          model: openai/mock-gpt
          api_key: sk-not-a-real-key
          mock_response: "VM test mock response."

    general_settings:
      database_url: os.environ/DATABASE_URL
      master_key: os.environ/LITELLM_MASTER_KEY
      store_model_in_db: true
  '';
in

testers.runNixOSTest {
  name = "litellm-proxy-postgres";

  nodes.machine =
    { pkgs, ... }:
    {
      # Headroom for prisma + python imports + initial migration.
      virtualisation.memorySize = 2048;
      virtualisation.cores = 2;
      virtualisation.diskSize = 4096;

      services.postgresql = {
        enable = true;
        # Create the role + database with a known password via initialScript
        # so the libpq URL `postgresql://litellm:litellm@localhost/litellm`
        # in DATABASE_URL actually authenticates.
        # We deliberately don't use `ensureUsers` because that runs AFTER
        # the initial script and overwrites our password setup.
        initialScript = pkgs.writeText "litellm-postgres-init.sql" ''
          CREATE USER ${dbUser} WITH PASSWORD '${dbPassword}' CREATEDB;
          CREATE DATABASE ${dbName} OWNER ${dbUser};
        '';
        # Use md5 auth on TCP so the password URL works against localhost.
        authentication = lib.mkOverride 10 ''
          local all all trust
          host all all 127.0.0.1/32 md5
          host all all ::1/128 md5
        '';
      };

      systemd.tmpfiles.rules = [
        "d ${stateDir} 0750 litellm litellm - -"
        "d ${stateDir}/prisma-cache 0750 litellm litellm - -"
        "d ${stateDir}/tiktoken 0750 litellm litellm - -"
      ];

      users.users.litellm = {
        isSystemUser = true;
        group = "litellm";
        home = stateDir;
      };
      users.groups.litellm = { };

      systemd.services.litellm = {
        description = "LiteLLM Proxy";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network-online.target"
          "postgresql.service"
        ];
        wants = [
          "network-online.target"
          "postgresql.service"
        ];

        path = [
          litellm
          prisma_6        # JS Prisma CLI v6 for schema management (prisma db push)
          prisma-engines  # v5 engines for prisma-client-py runtime queries
          postgresql      # libpq for prisma's connection probe
        ];

        environment = {
          DATABASE_URL = databaseUrl;
          LITELLM_MASTER_KEY = masterKey;
          # Defensive: also set in env even though wrapProgram already
          # does --set-default. This makes the env vars visible to the
          # `prisma` CLI subprocess that LiteLLM spawns for migrations.
          PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
          PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
          PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
          PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
          PRISMA_VERSION = prisma-engines.prismaVersion;
          PRISMA_EXPECTED_ENGINE_VERSION = prisma-engines.engineVersion;
          # Runtime caches must live somewhere writable; HOME is read-only
          # for system users by default.
          HOME = stateDir;
          XDG_CACHE_HOME = "${stateDir}/.cache";
          PRISMA_BINARY_CACHE_DIR = "${stateDir}/prisma-cache";
          CUSTOM_TIKTOKEN_CACHE_DIR = "${stateDir}/tiktoken";
          # Don't try to download nodeenv; we have a fully wired binary
          # toolchain already.
          PRISMA_USE_GLOBAL_NODE = "false";
          PRISMA_USE_NODEJS_BIN = "false";
          # Skip the remote fetch of model_prices_and_context_window.json;
          # the bundled local copy is sufficient for the test.
          LITELLM_LOCAL_MODEL_COST_MAP = "True";
        };

        serviceConfig = {
          Type = "simple";
          User = "litellm";
          Group = "litellm";
          WorkingDirectory = stateDir;
          # Pre-seed the tiktoken cache so the proxy doesn't try to download
          # cl100k_base.tiktoken on first import in a hermetic VM.
          ExecStartPre = "${seedTiktokenCacheScript}";
          ExecStart = lib.concatStringsSep " " [
            "${lib.getExe litellm}"
            "--host" "0.0.0.0"
            "--port" (toString port)
            "--config" "${litellmConfig}"
            # Use `prisma db push` (single subprocess to the system prisma
            # CLI on PATH) instead of `prisma migrate deploy` which goes
            # through prisma-client-py's bundled JS migrator. The latter
            # tries to install Node via nodeenv at runtime, which fails in
            # a hermetic VM.
            "--use_prisma_db_push"
          ];
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      networking.firewall.allowedTCPPorts = [ port ];

      environment.systemPackages = [
        curl
        postgresql
      ];
    };

  testScript = ''
    start_all()

    machine.wait_for_unit("postgresql.service")
    machine.succeed("sudo -u postgres psql -c 'SELECT 1' >/dev/null")

    # The proxy takes a while: it imports the full LiteLLM dependency
    # tree and runs `prisma db push` against the empty database to set up
    # the schema. Give it generous headroom on the slowest CI hardware.
    machine.wait_for_unit("litellm.service", timeout=300)
    machine.wait_for_open_port(${toString port}, timeout=300)

    # Health endpoint should return 200 once startup completed.
    machine.succeed(
        "curl --fail --max-time 30 http://localhost:${toString port}/health/readiness"
    )

    # Confirm prisma actually populated the schema (canary table).
    machine.succeed(
        "sudo -u postgres psql -d ${dbName} -c '\\dt' | grep -q LiteLLM_VerificationToken"
    )

    # Confirm the proxy reads its master key + DB and responds to a list-models
    # request. This requires both a working DB connection AND the prisma
    # client being properly generated.
    machine.succeed(
        "curl --fail --max-time 30 "
        "-H 'Authorization: Bearer ${masterKey}' "
        "http://localhost:${toString port}/v1/models | grep -q mock-gpt"
    )
  '';

  meta = {
    maintainers = with lib.maintainers; [ codgician ];
  };
}
