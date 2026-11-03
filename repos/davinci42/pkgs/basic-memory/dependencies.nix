{
  lib,
  fetchurl,
  python3Packages,
}:
let
  locked = builtins.fromJSON (builtins.readFile ./dependencies.json);
  wheel =
    name: dependencies: imports: license:
    python3Packages.buildPythonPackage {
      pname = name;
      inherit (locked.${name}) version;
      format = "wheel";
      src = fetchurl {
        inherit (locked.${name}) url;
        sha256 = locked.${name}.hash;
      };
      inherit dependencies;
      pythonRelaxDeps =
        lib.optionals (name == "fastapi") [ "opentelemetry-api" ]
        ++ lib.optionals (name == "litellm") [ "importlib-metadata" ];
      doCheck = false;
      pythonImportsCheck = imports;
      meta = {
        inherit license;
        sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
      };
    };
  packages = {
    fastapi =
      (wheel "fastapi" (with python3Packages; [
        annotated-doc
        opentelemetry-api
        pydantic
        starlette
        typing-extensions
        typing-inspection
      ]) [ "fastapi" ] lib.licenses.mit).overridePythonAttrs
        {
          passthru.optional-dependencies = python3Packages.fastapi.optional-dependencies;
        };
    fastapi-redis-sdk = wheel "fastapi-redis-sdk" (with python3Packages; [
      packages.fastapi
      anyio
      pydantic
      pydantic-settings
      redis
    ]) [ "redis_fastapi" "redis_fastapi.cache" ] lib.licenses.mit;
    mcp-types = wheel "mcp-types" (with python3Packages; [
      pydantic
      typing-extensions
    ]) [ "mcp_types" ] lib.licenses.mit;
    mcp = wheel "mcp" (
      with python3Packages;
      [
        packages.mcp-types
        anyio
        httpx2
        jsonschema
        opentelemetry-api
        pydantic
        pyjwt
        python-multipart
        sse-starlette
        starlette
        typing-extensions
        typing-inspection
        uvicorn
      ]
      ++ pyjwt.optional-dependencies.crypto
    ) [ "mcp" ] lib.licenses.mit;
    fastmcp-slim = wheel "fastmcp-slim" (
      with python3Packages;
      [
        packages.mcp
        packages.mcp-types
        authlib
        cyclopts
        exceptiongroup
        griffelib
        httpx2
        joserfc
        jsonref
        jsonschema-path
        openapi-pydantic
        opentelemetry-api
        packaging
        platformdirs
        py-key-value-aio
        pydantic
        pydantic-settings
        pyperclip
        python-dotenv
        python-multipart
        pyyaml
        rich
        starlette
        typing-extensions
        uncalled-for
        uvicorn
        watchfiles
        websockets
      ]
      ++ pydantic.optional-dependencies.email
      ++ py-key-value-aio.optional-dependencies.filetree
      ++ py-key-value-aio.optional-dependencies.keyring
      ++ py-key-value-aio.optional-dependencies.memory
    ) [ "fastmcp" "fastmcp.client" "fastmcp.server" ] lib.licenses.asl20;
    fastmcp = wheel "fastmcp" [ packages.fastmcp-slim ] [ "fastmcp" ] lib.licenses.asl20;
    litellm = wheel "litellm" (with python3Packages; [
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
      tiktoken
      tokenizers
    ]) [ "litellm" ] lib.licenses.mit;
  };
in
packages
