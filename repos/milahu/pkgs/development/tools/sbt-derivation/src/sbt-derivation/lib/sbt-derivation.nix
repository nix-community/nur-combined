{
  lib,
  stdenv,
  callPackage,
  sbt,
}: {
  pname,
  version,
  src,
  nativeBuildInputs ? [],
  passthru ? {},
  patches ? [],
  #
  # A function [final => prev => attrset] to override the dependencies derivation
  overrideDepsAttrs ? (_: _: {}),
  #
  # The sha256 of the dependencies
  depsSha256,
  #
  # Command to run to let sbt fetch all the required dependencies for the build.
  depsWarmupCommand ? "sbt compile",
  #
  # Strategy to use to package and unpackage the dependencies
  # - copy: regular directory, copy before build
  # - link: regular directory, use GNU stow to link files
  # - tar: tar archive, not compressed
  # - tar+zstd tar archive, compressed
  depsArchivalStrategy ? "tar+zstd",
  #
  # Whether to further reduce the side of the dependencies derivation by removing duplicate files
  depsOptimize ? true,
  ...
} @ args: let
  drvAttrs =
    removeAttrs args ["overrideDepsAttrs" "depsSha256" "depsWarmupCommand" "depsPackingStrategy" "depsOptimize"];

  # create a random temporary directory and configure sbt using environment
  # variables to use directories within it as a cache dir. we use the "project"
  # subdirectory so that all the dependencies can be extracted to the directory
  # with build.sbt and sbt will use them in --no-share mode, if the user finds
  # this convenient for testing.
  sbtEnvSetupCmds = ''
    export SBT_DEPS=$(mktemp -d)
    export SBT_OPTS="-Dsbt.global.base=$SBT_DEPS/project/.sbtboot -Dsbt.boot.directory=$SBT_DEPS/project/.boot -Dsbt.ivy.home=$SBT_DEPS/project/.ivy $SBT_OPTS"
    export COURSIER_CACHE=$SBT_DEPS/project/.coursier
    mkdir -p $SBT_DEPS/project/{.sbtboot,.boot,.ivy,.coursier}
  '';

  dependencies = (callPackage ./dependencies.nix {}) {
    inherit src patches nativeBuildInputs sbtEnvSetupCmds;

    namePrefix = "${pname}-sbt-dependencies";
    sha256 = depsSha256;
    warmupCommand = depsWarmupCommand;
    archivalStrategy = depsArchivalStrategy;
    optimize = depsOptimize;
    overrideAttrs = overrideDepsAttrs;
  };
in
  stdenv.mkDerivation (drvAttrs
    // {
      nativeBuildInputs = [sbt] ++ nativeBuildInputs;

      passthru =
        passthru
        // {
          inherit dependencies;
        };

      configurePhase = ''
        runHook preConfigure

        ${sbtEnvSetupCmds}
        ${dependencies.extractor} $SBT_DEPS

        runHook postConfigure
      '';
    })
