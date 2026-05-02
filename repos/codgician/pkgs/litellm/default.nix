# LiteLLM packaged independently from upstream nixpkgs so we can track the
# development branch closely (1.84.0-dev.2 here vs nixpkgs' stable 1.83.7).
#
# This file *also* fixes https://github.com/NixOS/nixpkgs/issues/432925
# ("litellm: missing prisma client") by wrapping the `litellm` executable
# with PRISMA_* environment variables that point at version-pinned engine
# binaries. See ./prisma-engines.nix for why we cannot use nixpkgs'
# prisma-engines_{6,7} here.

{
  lib,
  callPackage,
  fetchFromGitHub,
  python3Packages,
  makeWrapper,
  # Pin to Prisma 6 specifically: LiteLLM 1.84.0-dev.2 calls
  # `prisma db push --skip-generate`, and `--skip-generate` was removed
  # in Prisma 7. The CLI here is only used for one-shot schema management;
  # the version-sensitive runtime path (prisma-client-py querying postgres)
  # uses our pinned v5 engines.
  prisma_6,
  nodejs,
  # prisma-client-py shells out to `openssl version` at runtime to pick a
  # query-engine binary variant. Without it we get "Errno 2: No such file
  # or directory: 'openssl'" before anything else can happen.
  openssl,
  # NUR-local equivalent of `pkgs.nixosTests`, injected by ../default.nix.
  # Used in passthru below to follow the upstream nixpkgs convention of
  # `passthru.tests = { inherit (nixosTests) <package>; };`.
  nurTests,
}:

let
  version = "1.84.0-dev.2";

  # Single source of truth for all three packages in the LiteLLM monorepo:
  # main `litellm`, `litellm-proxy-extras`, and `litellm-enterprise`.
  src = fetchFromGitHub {
    owner = "BerriAI";
    repo = "litellm";
    rev = version;
    hash = "sha256-L3efqnullaaAs9orJ603SOxlj4H+loipupa/K4e9Jx0=";
  };

  # Pinned Prisma engines (v5.17.0 / commit 393aa359...). Required because
  # python3Packages.prisma is prisma-client-py 0.15.0 which only speaks the
  # v5 wire protocol. See ./prisma-engines.nix for full rationale.
  prisma-engines = callPackage ./prisma-engines.nix { };

  # Override python3Packages.prisma in two ways to fix #432925:
  #
  # 1. Drop its `prisma` console script. That script delegates to
  #    prisma-client-py's bundled JS migrator, which tries to install
  #    Node via nodeenv on first run. On a hermetic NixOS box that fails
  #    and the proxy cannot start. Removing the script forces
  #    `subprocess.run(['prisma', ...])` calls inside LiteLLM to resolve
  #    to `pkgs.prisma_6` on PATH (a self-contained Node binary).
  #
  # 2. Run `prisma generate` against LiteLLM's schema.prisma at build
  #    time, using the JS prisma_6 CLI as the orchestrator. The generated
  #    Python client code (prisma/client.py, prisma/models.py, etc.)
  #    lands directly in this derivation's site-packages so that
  #    `from prisma import Prisma` at runtime works without ever needing
  #    a generate step on the host. We patch out prisma-client-py's
  #    engine-version mismatch check so the generator accepts whatever
  #    engine version prisma_6 reports - the generated Python code
  #    doesn't actually depend on engine version, only the schema.
  #
  # We override at the python3Packages set level (via packageOverrides) so
  # every transitive consumer of `prisma` sees the patched version.
  py = python3Packages.python.override {
    self = py;
    packageOverrides = pyFinal: pyPrev: {
      prisma = pyPrev.prisma.overridePythonAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
          nodejs
          prisma_6
          prisma-engines
        ];

        # Drop the engine-version check in the generator so prisma_6's
        # JS CLI (engine commit c2990dca... in nixpkgs 25.11) can drive
        # our v5 prisma-client-py generator to emit Python source. The
        # generated code is engine-version-independent; the actual
        # version-sensitive runtime path uses our v5 query-engine.
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace src/prisma/generator/models.py \
            --replace-fail \
              "if not DEBUG_GENERATOR and version != config.expected_engine_version:" \
              "if False:"
        '';

        postFixup = (oldAttrs.postFixup or "") + ''
          # 1) Drop the broken `prisma` console script.
          rm -f $out/bin/prisma

          # 2) Pre-generate the Prisma Python client against LiteLLM's
          #    schema. This writes prisma/client.py etc. into
          #    $out/${pyPrev.python.sitePackages}/prisma/.
          export HOME=$(mktemp -d)
          export PRISMA_HIDE_UPDATE_MESSAGE=true
          export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines}/lib/libquery_engine.node"
          export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines}/bin/query-engine"
          export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-engines}/bin/schema-engine"
          export PRISMA_FMT_BINARY="${prisma-engines}/bin/prisma-fmt"

          # The generator subprocess prisma_6 spawns is `prisma-client-py`.
          # That binary lives in $out/bin/prisma-client-py - put it on PATH
          # so prisma_6 can find it. Also put $out/${pyPrev.python.sitePackages}
          # on PYTHONPATH so the binary's import of `prisma.generator` finds
          # our patched module.
          export PATH="$out/bin:$PATH"
          export PYTHONPATH="$out/${pyPrev.python.sitePackages}:$PYTHONPATH"

          # Avoid prisma_6's own engine downloads.
          export PRISMA_SKIP_POSTINSTALL_GENERATE=1

          # Run generate against the LiteLLM proxy schema.
          ${prisma_6}/bin/prisma generate \
            --schema=${src}/litellm/proxy/schema.prisma
        '';
      });
    };
  };
  pyPkgs = py.pkgs;

  # Optional dep redisvl is not in nixpkgs.
  redisvl = pyPkgs.callPackage ./redisvl.nix { };

  # Subpackage of the LiteLLM monorepo, lives at $src/litellm-proxy-extras/.
  # Only used by the `proxy` extra.
  litellm-proxy-extras = pyPkgs.buildPythonPackage {
    pname = "litellm-proxy-extras";
    version = "0.4.70";
    pyproject = true;

    inherit src;
    sourceRoot = "${src.name}/litellm-proxy-extras";

    # The upstream tarball ships historical release wheels in dist/. The
    # default install hook would pick them all up and conflict on overlap.
    # Also relax the strict `uv_build==0.10.7` build-system pin.
    postPatch = ''
      rm -rf dist
      substituteInPlace pyproject.toml \
        --replace-warn 'uv_build==0.10.7' 'uv_build'
    '';

    build-system = [ pyPkgs.uv-build ];

    # Pure resource package: ships a schema.prisma and migration helpers.
    # The actual logic lives in the main litellm package.
    dependencies = [ ];

    pythonImportsCheck = [ "litellm_proxy_extras" ];
    doCheck = false;

    meta = {
      description = "Additional files for the LiteLLM Proxy. Reduces the size of the main litellm package";
      homepage = "https://github.com/BerriAI/litellm";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ codgician ];
    };
  };

  # Subpackage of the LiteLLM monorepo, lives at $src/enterprise/.
  # Required for `import litellm_enterprise` paths inside the proxy.
  # NOTE: Proprietary license. Marked unfree-redistributable so it builds in
  # CI when allowUnfree is set.
  litellm-enterprise = pyPkgs.buildPythonPackage {
    pname = "litellm-enterprise";
    version = "0.1.39";
    pyproject = true;

    inherit src;
    sourceRoot = "${src.name}/enterprise";

    postPatch = ''
      rm -rf dist
      substituteInPlace pyproject.toml \
        --replace-warn 'uv_build==0.10.7' 'uv_build'
    '';

    build-system = [ pyPkgs.uv-build ];

    dependencies = with pyPkgs; [
      fastapi
      pydantic
    ];

    pythonImportsCheck = [ "litellm_enterprise" ];
    doCheck = false;

    meta = {
      description = "Package for LiteLLM Enterprise features";
      homepage = "https://github.com/BerriAI/litellm";
      license = with lib.licenses; [
        # LicenseRef-Proprietary - source-available, not OSI-approved.
        unfreeRedistributable
      ];
      maintainers = with lib.maintainers; [ codgician ];
    };
  };

  # The Python library version of litellm (with proxy + extra_proxy bundled).
  # Mirrors the layered structure used by upstream nixpkgs (python module +
  # toPythonApplication wrapper).
  litellm-python = pyPkgs.buildPythonPackage {
    pname = "litellm";
    inherit version src;
    pyproject = true;

    build-system = [ pyPkgs.uv-build ];

    # Patch out optional deps we deliberately don't package:
    #   - pyroscope-io: profiling-only optional. Not in nixpkgs and not
    #     activated unless the user explicitly enables Pyroscope at runtime.
    # Also relax strict version pins so we can use whatever nixpkgs ships,
    # and drop the historical release artifacts shipped in dist/.
    postPatch = ''
      rm -rf dist
      sed -i '/pyroscope-io==/d' pyproject.toml
      substituteInPlace pyproject.toml \
        --replace-warn 'uv_build==0.10.7' 'uv_build' \
        --replace-warn 'litellm-proxy-extras==0.4.70' 'litellm-proxy-extras' \
        --replace-warn 'litellm-enterprise==0.1.39' 'litellm-enterprise'
    '';



    pythonRelaxDeps = true;

    dependencies = with pyPkgs; [
      aiohttp
      click
      fastuuid
      httpx
      importlib-metadata
      jinja2
      jsonschema
      openai
      pydantic
      python-dotenv
      requests
      tiktoken
      tokenizers
    ];

    optional-dependencies = with pyPkgs; {
      proxy = [
        apscheduler
        azure-identity
        azure-storage-blob
        backoff
        boto3
        cryptography
        fastapi
        fastapi-sso
        gunicorn
        litellm-enterprise
        litellm-proxy-extras
        mcp
        orjson
        polars
        pyjwt
        pynacl
        python-multipart
        pyyaml
        restrictedpython
        rich
        rq
        soundfile
        uvicorn
        uvloop
        websockets
      ];

      extra_proxy = [
        a2a-sdk
        azure-identity
        azure-keyvault-secrets
        google-cloud-iam
        google-cloud-kms
        prisma          # picks up our packageOverrides patch
        redisvl
        resend
      ];
    };

    pythonImportsCheck = [
      "litellm"
      "litellm_enterprise"
      "litellm_proxy_extras"
    ];

    # Tests need network and many of the cloud provider SDKs at runtime.
    doCheck = false;

    passthru = {
      inherit
        prisma-engines
        litellm-proxy-extras
        litellm-enterprise
        redisvl
        ;
    };

    meta = {
      description = "Use any LLM as a drop-in replacement for gpt-3.5-turbo";
      mainProgram = "litellm";
      homepage = "https://github.com/BerriAI/litellm";
      changelog = "https://github.com/BerriAI/litellm/releases/tag/${version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ codgician ];
    };
  };

  # Nixpkgs-style application wrapper. Pulls in the full proxy + extra_proxy
  # dependency closure so `litellm --port ... --config ...` works out of the
  # box, and wraps the binary with PRISMA_* env vars that fix #432925.
  litellm-app = pyPkgs.toPythonApplication (
    litellm-python.overridePythonAttrs (oldAttrs: {
      dependencies =
        (oldAttrs.dependencies or [ ])
        ++ oldAttrs.optional-dependencies.proxy
        ++ oldAttrs.optional-dependencies.extra_proxy;

      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

      # Wrap `litellm` (and the proxy CLI) with two important pieces of
      # environment, both required to fix NixOS/nixpkgs#432925:
      #
      # 1. PRISMA_* engine env vars pointing at the v5.17.0 engines we
      #    shipped, so prisma-client-py finds binaries on disk instead of
      #    trying to download them at runtime.
      #
      # 2. PATH that puts the system Prisma JS CLI (pkgs.prisma) BEFORE the
      #    `prisma` shim that python3Packages.prisma installs. The shim
      #    delegates everything to prisma-client-py's bundled JS migrator,
      #    which in turn tries to install Node via `python -m nodeenv`,
      #    which fails offline. The system prisma CLI is a self-contained
      #    Node binary that just works for `prisma db push` /
      #    `prisma migrate deploy`.
      #
      # --set-default lets users still override these for e.g. an external
      # binary cache directory.
      postFixup = (oldAttrs.postFixup or "") + ''
        for prog in $out/bin/litellm $out/bin/litellm-proxy; do
          [ -e "$prog" ] || continue
          wrapProgram "$prog" \
            --prefix PATH : "${lib.makeBinPath [ prisma_6 (lib.getBin openssl) ]}" \
            --set-default PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines}/lib/libquery_engine.node" \
            --set-default PRISMA_QUERY_ENGINE_BINARY "${prisma-engines}/bin/query-engine" \
            --set-default PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines}/bin/schema-engine" \
            --set-default PRISMA_FMT_BINARY "${prisma-engines}/bin/prisma-fmt" \
            --set-default PRISMA_VERSION "${prisma-engines.prismaVersion}" \
            --set-default PRISMA_EXPECTED_ENGINE_VERSION "${prisma-engines.engineVersion}"
        done
      '';
    })
  );
in

litellm-app.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    # Expose the bare python module for downstream consumers that want to
    # depend on `litellm` as a library rather than as an application.
    python = litellm-python;

    inherit
      prisma-engines
      litellm-proxy-extras
      litellm-enterprise
      redisvl
      ;

    # Wire the VM test back via passthru, mirroring nixpkgs's
    # `passthru.tests = { inherit (nixosTests) <pkg>; };` idiom. The test
    # definition lives at /tests/litellm.nix and is registered in
    # /tests/default.nix.
    tests = { inherit (nurTests) litellm; };

    updateScript = ./update.sh;
  };

  meta = oldAttrs.meta // {
    longDescription = ''
      Independent NUR packaging of LiteLLM tracking the development branch
      (currently ${version}). Wraps the `litellm` binary with Prisma engine
      environment variables, fixing the "missing prisma client" startup
      failure that affects upstream nixpkgs (NixOS/nixpkgs#432925).

      The `pyroscope-io` profiling backend is intentionally omitted to keep
      the package light; it is an optional profiling dependency that is not
      activated unless the user explicitly enables Pyroscope at runtime.
      All other proxy + extra_proxy dependencies are included.

      Run the bundled NixOS VM test (postgres + prisma migration) with:
        nix build .#litellm.tests.litellm
      or via the top-level test attrset:
        nix build .#tests.litellm
      or as a flake check:
        nix build .#checks.<system>.litellm
    '';
    platforms = lib.platforms.linux;
  };
})
