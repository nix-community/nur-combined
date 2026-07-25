{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  makeWrapper,
  nodejs,
  node-gyp,
  python3,
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
    nodejs
    node-gyp
    python3
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.cctools;

  buildInputs = [ sqlite ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    cp -R ${nodeModules}/node_modules ./
    chmod -R u+w node_modules
    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qmd $out/bin
    cp -r node_modules src package.json $out/lib/qmd/

    makeWrapper ${lib.getExe bun} $out/bin/qmd \
      --add-flags "$out/lib/qmd/src/cli/qmd.ts" \
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
