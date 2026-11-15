{
  # keep-sorted start
  bun,
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    fetchers
    getExe
    # keep-sorted end
    ;

  version = "0.3.5-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "grab";
    repo = "cursor-talk-to-figma-mcp";
    rev = "ddd90f3a6d454ea0b2fc29f1b084f50fd062b880";
    hash = "sha256-yc+uIHYHB/dWro7PlPjwkh2Hsz2FaKDy0ZXHJ8VkQJc=";
  };

  dependencyHash = "sha256-NHdKGVk3Me+2GVh3OT7kOzCcKBWyVgd62cU3NEtwXHk=";

  # Bun has no lockfile fetcher in nixpkgs, so a fixed-output install pins the modules.
  nodeModules = stdenvNoCC.mkDerivation {
    pname = "talk-to-figma-mcp-node-modules";
    inherit
      # keep-sorted start
      src
      version
      # keep-sorted end
      ;

    nativeBuildInputs = [bun];
    impureEnvVars = fetchers.proxyImpureEnvVars;

    # Bun releases hoist differently; the isolated layout follows the lockfile, keeping the hash stable.
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --frozen-lockfile --production --ignore-scripts --no-progress --linker isolated
      runHook postBuild
    '';

    # Keeps the node_modules directory so resolution from store realpaths finds siblings.
    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r node_modules $out/
      runHook postInstall
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = dependencyHash;
  };
in
  stdenvNoCC.mkDerivation {
    pname = "talk-to-figma-mcp";
    inherit
      # keep-sorted start
      src
      version
      # keep-sorted end
      ;

    nativeBuildInputs = [makeWrapper];

    # Bun binds every interface by default; the relay is unauthenticated.
    postPatch = ''
      substituteInPlace src/socket.ts --replace-fail 'port: 3055,' 'port: 3055, hostname: "127.0.0.1",'
    '';

    dontBuild = true;

    # Bun runs the TypeScript sources directly, so no bundling step is needed.
    installPhase = ''
      runHook preInstall

      lib=$out/lib/talk-to-figma-mcp
      mkdir -p $lib
      cp -r package.json src $lib/
      ln -s ${nodeModules}/node_modules $lib/node_modules

      makeWrapper ${getExe bun} $out/bin/talk-to-figma-mcp --add-flags "run $lib/src/talk_to_figma_mcp/server.ts"
      makeWrapper ${getExe bun} $out/bin/talk-to-figma-relay --add-flags "run $lib/src/socket.ts"

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      export HOME="$TMPDIR"

      # The server keeps retrying the relay after stdin closes, so timeout ends it.
      output=$(printf '%s\n' \
        '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "check", "version": "0"}}}' \
        '{"jsonrpc": "2.0", "method": "notifications/initialized"}' \
        '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}' |
        timeout 20 $out/bin/talk-to-figma-mcp 2>/dev/null || true)

      grep -F '"name":"join_channel"' <<< "$output" > /dev/null
      runHook postInstallCheck
    '';

    passthru = {inherit nodeModules;};

    meta = with lib; {
      # keep-sorted start
      description = "MCP server and WebSocket relay that let agents read and edit Figma through a plugin";
      homepage = "https://github.com/grab/cursor-talk-to-figma-mcp";
      license = licenses.mit;
      mainProgram = "talk-to-figma-mcp";
      platforms = platforms.unix;
      # keep-sorted end
    };
  }
