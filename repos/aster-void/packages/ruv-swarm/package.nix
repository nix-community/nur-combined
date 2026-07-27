{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  python3,
  jq,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ruv-swarm";
  version = "1.0.18";

  src = fetchFromGitHub {
    owner = "ruvnet";
    repo = "ruv-FANN";
    rev = "f0f837f0d22ca1dc09f058d0270c60c9bc07fad3";
    hash = "sha256-AA09Osu0ndTSLiyQae1IVII82twMttIMBksKZe7RwmI=";
  };

  sourceRoot = "${finalAttrs.src.name}/ruv-swarm/npm";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src sourceRoot;
    fetcherVersion = 2;
    hash = "sha256-fBNtHtFj7tYWF8mnIEGN5q66GMd9546WkFC54yFULp0=";
    # Use our generated pnpm-lock.yaml and remove optionalDependencies
    postPatch = ''
      ${lib.getExe jq} 'del(.optionalDependencies)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./pnpm-lock.yaml} pnpm-lock.yaml
    '';
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    (python3.withPackages (ps: [ps.setuptools])) # for better-sqlite3 node-gyp
    pkg-config
  ];

  # Use local node headers instead of downloading
  npm_config_nodedir = nodejs;

  preConfigure = ''
    ${lib.getExe jq} 'del(.optionalDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./pnpm-lock.yaml} pnpm-lock.yaml
  '';

  # Patch persistence files to use RUV_SWARM_DATA_DIR environment variable
  postPatch = ''
    substituteInPlace src/persistence-pooled.js \
      --replace-fail \
        "constructor(dbPath = path.join(new URL('.', import.meta.url).pathname, '..', 'data', 'ruv-swarm.db')" \
        "constructor(dbPath = path.join(process.env.RUV_SWARM_DATA_DIR || path.join(new URL('.', import.meta.url).pathname, '..', 'data'), 'ruv-swarm.db')"
    substituteInPlace src/persistence.js \
      --replace-fail \
        "constructor(dbPath = path.join(new URL('.', import.meta.url).pathname, '..', 'data', 'ruv-swarm.db'))" \
        "constructor(dbPath = path.join(process.env.RUV_SWARM_DATA_DIR || path.join(new URL('.', import.meta.url).pathname, '..', 'data'), 'ruv-swarm.db'))"
  '';

  # Rebuild native modules (better-sqlite3 requires node-gyp build)
  buildPhase = ''
    runHook preBuild

    # Find and build better-sqlite3 native module
    pushd node_modules/.pnpm/better-sqlite3@*/node_modules/better-sqlite3
    npm run build-release
    popd

    runHook postBuild
  '';

  installPhase = ''
        runHook preInstall

        mkdir -p $out/libexec/ruv-swarm $out/bin
        cp -r bin src node_modules package.json $out/libexec/ruv-swarm/

        # Clean up node_modules to reduce size
        find $out/libexec/ruv-swarm/node_modules -type d -name obj.target -prune -exec rm -rf {} +
        find $out/libexec/ruv-swarm/node_modules -name '*.o' -delete
        find $out/libexec/ruv-swarm/node_modules -name '*.a' -delete
        find $out/libexec/ruv-swarm/node_modules -type d -name 'test' -prune -exec rm -rf {} +
        find $out/libexec/ruv-swarm/node_modules -type d -name 'tests' -prune -exec rm -rf {} +
        find $out/libexec/ruv-swarm/node_modules -type d -name '__tests__' -prune -exec rm -rf {} +
        find $out/libexec/ruv-swarm/node_modules -type d -name 'docs' -prune -exec rm -rf {} +
        find $out/libexec/ruv-swarm/node_modules -name '*.md' -delete
        find $out/libexec/ruv-swarm/node_modules -name '*.map' -delete
        find $out/libexec/ruv-swarm/node_modules -name '*.ts' ! -name '*.d.ts' -delete

        cat > $out/bin/ruv-swarm << 'EOF'
    #!/usr/bin/env bash
    export RUV_SWARM_DATA_DIR="''${RUV_SWARM_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/ruv-swarm}"
    EOF
        echo "exec ${lib.getExe nodejs} $out/libexec/ruv-swarm/bin/ruv-swarm-secure.js \"\$@\"" >> $out/bin/ruv-swarm
        chmod +x $out/bin/ruv-swarm

        runHook postInstall
  '';

  meta = {
    description = "Distributed swarm orchestration CLI with MCP support";
    longDescription = ''
      ruv-swarm is a swarm orchestration system that provides native
      integration with Claude Code through the Model Context Protocol (MCP).
      Features include swarm initialization, agent spawning, and task orchestration.
    '';
    homepage = "https://github.com/ruvnet/ruv-FANN";
    license = with lib.licenses; [mit asl20];
    maintainers = [];
    mainProgram = "ruv-swarm";
  };
})
