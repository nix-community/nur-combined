{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  nodejs,
  pnpm,
  makeBinaryWrapper,
  python3,
  pkgConfig,
  cmake,
  ninja,
  which,
  runCommand,
}: let
  version = "0.9.5";
  pythonEnv = python3.withPackages (ps: with ps; [ps.setuptools ps.distutils]);
  pythonSitePackages = lib.makeSearchPath "lib/python${python3.pythonVersion}/site-packages" (
    with python3.pkgs; [setuptools distutils]
  );
  duckdbBinaryFile = "duckdb-v1.4.1-node-v127-linux-x64.tar.gz";
  duckdbBinary = fetchurl {
    url = "https://npm.duckdb.org/duckdb/${duckdbBinaryFile}";
    hash = "sha256-gyX6jn/NuJgwbDT7TqApzZaAENLxOoiUPimVSrIDs6o=";
  };
  duckdbMirror = runCommand "duckdb-mirror" {} ''
    mkdir -p $out
    cp ${duckdbBinary} $out/${duckdbBinaryFile}
  '';
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "kiri";
    inherit version;
    dontUseCmakeConfigure = true;

    src = fetchFromGitHub {
      owner = "CAPHTECH";
      repo = "kiri";
      tag = "v${version}";
      hash = "sha256-75lBO8NdYFPzxyMS9/G2RL6xfkwuDX3zAtOWUIH36dc=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-krYMHEwSrD1pXCUJl6NYjc9lXfRrm1u9AUZs+dl6H8c=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpm.configHook
      pythonEnv
      pkgConfig
      cmake
      ninja
      which
      makeBinaryWrapper
    ];

    env = {
      npm_config_nodedir = "${nodejs}";
      npm_config_python = "${pythonEnv}/bin/python3";
      npm_config_offline = "true";
      npm_config_duckdb_binary_host_mirror = "file://${duckdbMirror}";
      PYTHON = "${pythonEnv}/bin/python3";
      PYTHONPATH = pythonSitePackages;
      HOME = "/tmp";
    };

    configurePhase = ''
      runHook preConfigure
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      pnpm rebuild duckdb tree-sitter tree-sitter-php tree-sitter-swift
      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      installRoot=$out/share/kiri
      mkdir -p "$installRoot" $out/bin

      cp package.json pnpm-lock.yaml README.md LICENSE "$installRoot"
      cp -r dist config sql node_modules "$installRoot"

      # drop bulky intermediate objects produced by node-gyp builds
      find "$installRoot/node_modules" -type d -name obj.target -prune -exec rm -rf {} +
      find "$installRoot/node_modules" -name '*.o' -delete

      for bin in kiri kiri-mcp-server kiri-server kiri-daemon; do
        script="dist/src/client/proxy.js"
        case "$bin" in
          kiri-server) script="dist/src/server/main.js" ;;
          kiri-daemon) script="dist/src/daemon/daemon.js" ;;
        esac
        makeWrapper ${lib.getExe nodejs} "$out/bin/$bin" \
          --add-flags "$installRoot/$script" \
          --set NODE_ENV production \
          --set-default KIRI_HOME "$installRoot"
      done

      runHook postInstall
    '';

    meta = with lib; {
      description = "Context extraction platform and MCP server";
      homepage = "https://github.com/CAPHTECH/kiri";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.linux;
      mainProgram = "kiri";
    };
  })
