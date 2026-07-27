{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  python3,
  makeBinaryWrapper,
  jq,
  runCommand,
}: let
  version = "2.7.34";

  src = fetchFromGitHub {
    owner = "ruvnet";
    repo = "claude-flow";
    tag = "v${version}";
    hash = "sha256-20dMNAihqY6oiBjDUKHj/IlGn9gVyQOOGbVlIrWksv0=";
  };

  patchLockfile = ''
    # Remove worker_threads from ruv-swarm's optionalDependencies
    # worker_threads is a Node.js built-in module, not an npm package
    ${lib.getExe jq} 'walk(if type == "object" and .optionalDependencies.worker_threads? then .optionalDependencies |= del(.worker_threads) else . end)' package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  '';

  patchedSrc =
    runCommand "claude-flow-patched-src" {
      inherit src;
      nativeBuildInputs = [jq];
    } ''
      cp -r $src $out
      chmod -R +w $out
      cd $out
      ${patchLockfile}
    '';
in
  buildNpmPackage {
    pname = "claude-flow";
    inherit version;

    src = patchedSrc;

    npmDepsHash = "sha256-os9pfIxe0dzgFmHddm8f/mrDyN3SeeBx8HF95Yt6bNw=";

    makeCacheWritable = true;
    npmFlags = ["--legacy-peer-deps"];

    nativeBuildInputs = [
      makeBinaryWrapper
      python3
    ];

    dontNpmInstall = true;
    npmRebuildFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild
      npm run clean
      npm run build:esm
      npm run build:cjs
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/claude-flow $out/bin

      # Copy all necessary files including src for sourcemap resolution
      cp -r dist dist-cjs node_modules package.json bin scripts src $out/share/claude-flow/

      makeWrapper ${lib.getExe nodejs} $out/bin/claude-flow \
        --add-flags "$out/share/claude-flow/dist/src/cli/main.js" \
        --set NODE_ENV production \
        --set NODE_PATH "$out/share/claude-flow/node_modules"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Enterprise-grade AI agent orchestration platform for Claude";
      homepage = "https://github.com/ruvnet/claude-flow";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.linux;
      mainProgram = "claude-flow";
    };
  }
