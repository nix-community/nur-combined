{
  lib,
  fetchFromGitHub,
  nix-update,
  nix,
  git,
  writeShellApplication,
  callPackage,
  python3,
  python3Packages,
}:
let
  pythonPackages = python3Packages // callPackage ./dependencies.nix { };
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "basic-memory";
  version = "0.23.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "basicmachines-co";
    repo = "basic-memory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-etL0RHkSNFzT00p3yCBtH92XDaqwakDO8Eurf+dS3ug=";
  };

  build-system = with pythonPackages; [
    hatchling
    uv-dynamic-versioning
  ];

  env.UV_DYNAMIC_VERSIONING_BYPASS = finalAttrs.version;

  pythonRelaxDeps = [ "psycopg" ];

  pythonRemoveDeps = [
    "pyright"
    "pytest-aio"
    "pytest-asyncio"
  ];

  dependencies =
    with pythonPackages;
    [
      aiofiles
      aiosqlite
      alembic
      anyio
      asyncpg
      dateparser
      fastapi
      fastembed
      fastmcp
      filelock
      greenlet
      httpx
      litellm
      logfire
      loguru
      markdown-it-py
      mcp
      mdformat
      mdformat-frontmatter
      mdformat-gfm
      nest-asyncio
      openai
      pillow
      psutil
      psycopg
      pybars3
      pydantic
      pydantic-settings
      pyjwt
      python-dotenv
      python-frontmatter
      pyyaml
      rich
      sniffio
      sqlalchemy
      sqlite-vec
      typer
      tzdata
      unidecode
      uvloop
      watchfiles
    ]
    ++ fastapi.optional-dependencies.standard
    ++ pydantic.optional-dependencies.email;

  doCheck = false;
  pythonImportsCheck = [
    "basic_memory"
    "basic_memory.cli.main"
    "basic_memory.mcp.server"
  ];
  preCheck = ''
    export HOME="$TMPDIR"
    export BASIC_MEMORY_AUTO_UPDATE=false
    export BASIC_MEMORY_NO_PROMOS=1
    export BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-basic-memory";
      runtimeInputs = [
        python3
        nix-update
        nix
        git
      ];
      text = ''
        exec python3 pkgs/basic-memory/update.py "$@"
      '';
    });
    tests.packaging = callPackage ../../tests/pkgs/basic-memory.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Local-first Markdown knowledge graph and MCP memory server";
    homepage = "https://github.com/basicmachines-co/basic-memory";
    license = lib.licenses.agpl3Plus;
    mainProgram = "basic-memory";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
