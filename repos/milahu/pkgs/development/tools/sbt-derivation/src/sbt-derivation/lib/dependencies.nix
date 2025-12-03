{
  bc,
  callPackage,
  file,
  findutils,
  gnused,
  lib,
  rdfind,
  sbt,
  stdenv,
  strip-nondeterminism,
  symlinks,
  writeShellScript,
}: {
  namePrefix,
  sbtEnvSetupCmds,
  src,
  patches ? [],
  sha256,
  warmupCommand,
  nativeBuildInputs ? [],
  archivalStrategy,
  optimize,
  overrideAttrs,
} @ args: let
  archivalStrategy = (callPackage ./archival-strategies.nix {}).${args.archivalStrategy};

  mkAttrs = drv: {
    inherit src patches;

    name = namePrefix + archivalStrategy.fileExtension;

    nativeBuildInputs =
      [sbt gnused strip-nondeterminism file findutils]
      ++ nativeBuildInputs
      ++ archivalStrategy.nativeBuildInputs;

    outputHash = sha256;
    outputHashAlgo = "sha256";
    inherit (archivalStrategy) outputHashMode;

    dontConfigure = true;

    impureEnvVars =
      lib.fetchers.proxyImpureEnvVars
      ++ ["GIT_PROXY_COMMAND" "SOCKS_SERVER"];

    buildPhase = ''
      runHook preBuild

      ${sbtEnvSetupCmds}

      echo "running:"
      ${let
        matches = builtins.match ''
          [[:space:]]*([[:graph:]](.|
          )*[[:graph:]])[[:space:]]*''
        warmupCommand;
        cleanCommand = builtins.elemAt matches 0;
        lines = lib.splitString "\n" cleanCommand;
      in
        lib.concatMapStringsSep "\n" (l: ''echo ">" ${lib.escapeShellArg l}'') lines}
        echo "...to warm up the dependencies' caches"
        ${warmupCommand}

        echo "stripping out comments containing dates"
        find $SBT_DEPS/project -name '*.properties' -type f -exec sed -i '/^#/d' {} \;

        echo "removing non-reproducible accessory files"
        find $SBT_DEPS/project -name '*.lock' -type f -print0 | xargs -r0 rm -rfv
        find $SBT_DEPS/project -name '*.log' -type f -print0 | xargs -r0 rm -rfv

        echo "fixing-up the compiler bridge and interface"
        find $SBT_DEPS/project -name 'org.scala-sbt-compiler-bridge_*' -type f -print0 | xargs -r0 strip-nondeterminism
        find $SBT_DEPS/project -name 'org.scala-sbt-compiler-interface_*' -type f -print0 | xargs -r0 strip-nondeterminism

        echo "removing runtime jar"
        find $SBT_DEPS/project -name rt.jar -delete

        echo "removing empty directories"
        find $SBT_DEPS/project -type d -empty -delete

        runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      ${lib.optionalString optimize ''
        (
          umask 000
          ${rdfind}/bin/rdfind -makesymlinks true -outputname /dev/null $SBT_DEPS/project/{.sbtboot,.boot,.ivy,.coursier}
          ${symlinks}/bin/symlinks -rc $SBT_DEPS/project
        )
      ''}
        ${archivalStrategy.packerFragment}

        runHook postInstall
    '';

    passthru.extractor = writeShellScript "extract-dependencies" ''
      set -euo pipefail

      export PATH=${lib.escapeShellArg (lib.makeBinPath (archivalStrategy.nativeBuildInputs ++ [bc]))}":$PATH"

      if [[ "$#" -eq 0 ]]; then
      echo "Usage: $0 <dest-dir> – where dest-dir is usually where the project build.sbt is placed" 2>&1
      exit 1
      fi

      target="$1"

      echo "extracting dependencies in $target"
      mkdir -p "$target/project"

      start="$(date +%s.%N)"
      ${archivalStrategy.extractorFragment drv}
      end="$(date +%s.%N)"
      runtime="$(echo "$end - $start" | bc -l)"

      echo "done in $runtime seconds"
    '';

    passthru.fetcher = {sha256}: drv.overrideAttrs (_: {inherit sha256;});
  };
in
  lib.fix (drv:
    stdenv.mkDerivation (
      let
        materializedAttrs = mkAttrs drv;
        overrides = lib.fix (final: overrideAttrs final materializedAttrs);
      in
        materializedAttrs // overrides
    ))
