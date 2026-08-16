{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  makeWrapper,
  nodejs_26,
  node-gyp,
  python3,
  cmake,
  git,
  coreutils,
  sqlite,
  darwin ? null,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version;
  system = stdenv.hostPlatform.system;
  targets = {
    "aarch64-darwin" = {
      os = "darwin";
      cpu = "arm64";
    };
    "aarch64-linux" = {
      os = "linux";
      cpu = "arm64";
    };
    "x86_64-linux" = {
      os = "linux";
      cpu = "x64";
    };
  };
  target = targets.${system} or (throw "qmd: unsupported system ${system}");

  # node-llama-cpp's localBuilds layout, e.g. linux-arm64, darwin-arm64.
  llamaTarget = "${target.os}-${target.cpu}";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    inherit (versionData) rev;
    hash = versionData.sourceHash;
  };

  nodeModulesHash = versionData.nodeModulesHashes.${system};

  nodeModules = stdenvNoCC.mkDerivation {
    pname = "qmd-node-modules";
    inherit version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];
    nativeBuildInputs = [ bun ];
    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      bun install \
        --backend copyfile \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production \
        --os ${target.os} \
        --cpu ${target.cpu}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/

      runHook postInstall
    '';

    dontFixup = true;
    outputHash = nodeModulesHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  pname = "qmd";
  inherit version src;

  nativeBuildInputs = [
    bun
    makeWrapper
    nodejs_26
    node-gyp
    python3
    cmake
    git
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.cctools;

  buildInputs = [ sqlite ];

  # cmake is only here to build node-llama-cpp's llama.cpp backend in
  # buildPhase; qmd itself has no CMakeLists. Keep stdenv's cmake hook
  # from trying to configure the package.
  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    cp -R ${nodeModules}/node_modules ./
    chmod -R u+w node_modules
    # the vendored bins have /usr/bin/env shebangs, absent in the sandbox
    # (node-llama-cpp's build shells out to npm run / cmake-js). The .bin
    # entries are symlinks, so patch the whole tree, not just .bin.
    patchShebangs node_modules
    # node-gyp's nixpkgs wrapper points npm_config_nodedir at ITS node 24;
    # build the binding against the node we pin at runtime instead (ABI).
    export npm_config_nodedir=${nodejs_26}
    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)

    # node-llama-cpp ships no linux-aarch64 prebuilt, and at runtime it can
    # only build into its own package dir — read-only in the nix store.
    # Build the llama.cpp backend here instead; getLlama() prefers these
    # localBuilds. The source comes from the bundled git bundle (offline).
    #
    # Two environment traps: the .bin shims' /usr/bin/env shebangs do not
    # exist in the sandbox (invoke with node directly), and the 3.18.1 CLI
    # spins forever after a successful tty-less compile — the artifacts are
    # complete by then, so bound it with timeout and assert the output.
    (
      cd node_modules/node-llama-cpp/llama
      git clone --quiet gitRelease.bundle llama.cpp
      ${lib.getExe' coreutils "timeout"} --kill-after=30 1200 \
        ${lib.getExe nodejs_26} ../dist/cli/cli.js source build --noUsageExample || true
      test -f localBuilds/${llamaTarget}/Release/llama-addon.node
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qmd $out/bin
    cp -r node_modules src package.json $out/lib/qmd/

    # Pin the node qmd spawns for its subprocesses: must match the ABI
    # better-sqlite3 was built against above, and node 24.19.0 has the
    # RemoveEnvironmentCleanupHook teardown regression (nodejs/node#63923).
    makeWrapper ${lib.getExe bun} $out/bin/qmd \
      --add-flags "$out/lib/qmd/src/cli/qmd.ts" \
      --prefix PATH : ${nodejs_26}/bin \
      --set DYLD_LIBRARY_PATH "${lib.getLib sqlite}/lib" \
      --set LD_LIBRARY_PATH "${lib.getLib sqlite}/lib"

    runHook postInstall
  '';

  meta = {
    description = "On-device search engine for Markdown and knowledge bases";
    homepage = "https://github.com/tobi/qmd";
    license = lib.licenses.mit;
    mainProgram = "qmd";
    platforms = builtins.attrNames versionData.nodeModulesHashes;
  };
}
