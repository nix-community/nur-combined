{ mkShell
, rustChannel, rustChannelPlatform
, pkgs
, stdenv
, pkgsCross
, cargo-download, cargo-expand ? null, cargo-outdated ? null, cargo-release, cargo-bloat ? null
, cargo-llvm-lines ? null, cargo-deps ? null, cargo-with ? null, cargo-readme ? null
, rust-analyzer
}: with pkgs.lib; let
  rustTools' = [ cargo-download cargo-expand cargo-outdated cargo-release cargo-bloat cargo-llvm-lines cargo-deps cargo-with cargo-readme rust-analyzer ];
  rustTools = builtins.filter (pkg: pkg.meta.available or true) rustTools';
  rustExtensions = [
    "clippy-preview" "rustfmt-preview" # "llvm-tools-preview" broken? :(
    "rust-analysis" "rls-preview" "rust-src"
  ];
  channels = { inherit (rustChannel) stable nightly; };
  pkgs' = pkgs;
  fillTarget = {
    triple
  , pkgs ? pkgs'
  , stdenv ? pkgs.stdenv
  , cc ? stdenv.cc
  , ar ? "${cc}/bin/${cc.targetPrefix}ar"
  , linker ? "${cc}/bin/${cc.targetPrefix}cc"
  , linkerFlavor ? "gcc" # em gcc ld msvc ptx-linker wasm-ld ld64.lld ld.lld lld-link
  }: {
    inherit triple pkgs stdenv cc ar linker linkerFlavor;
  };
  targetCompat = {
    i686-pc-mingw32 = {
      inherit (targets.mingw32) triple;
    };
    x86_64-pc-mingw32 = {
      inherit (targets.mingwW64) triple;
    };
  };
  targetFor = pkgs: {
    inherit (pkgs);
    triple = pkgs.hostPlatform.config;
  };
  targets = rec {
    armv6m = {
      triple = "thumbv6m-none-eabi";
      pkgs = pkgsCross.arm-embedded;
    };
    armv7m = {
      triple = "thumbv7m-none-eabi";
      pkgs = pkgsCross.arm-embedded;
    };
    armv7me = {
      triple = "thumbv7me-none-eabi";
      pkgs = pkgsCross.arm-embedded;
    };
    armv7mef = {
      triple = "thumbv7me-none-eabihf";
      pkgs = pkgsCross.armhf-embedded;
    };
    mingwW64 = {
      triple = "x86_64-pc-windows-gnu";
      pkgs = pkgsCross.mingwW64;
    };
    mingw32 = {
      triple = "i686-pc-windows-gnu";
      pkgs = pkgsCross.mingw32;
    };
    win64 = {
      triple = "x86_64-pc-windows-msvc";
      # TODO: wine link.exe stdenv
    };
    win32 = {
      triple = "i686-pc-windows-msvc";
    };
    macos64 = {
      triple = "x86_64-apple-darwin";
    };
    macos32 = {
      triple = "i686-apple-darwin";
    };
    linux32 = targetFor pkgsCross.gnu32;
    linux64 = targetFor pkgsCross.gnu64;
    musl32 = targetFor pkgsCross.musl32;
    musl64 = targetFor pkgsCross.musl64;
    wasi32 = {
      triple = "wasm32-wasi";
      pkgs = pkgsCross.wasi32;
    };
    aarch64 = targetFor pkgsCross.aarch64-multiplatform;
    iphone32 = {
      triple = "armv7-apple-ios";
      pkgs = pkgsCross.iphone32;
    };
    iphone32-simulator = {
      triple = "i386-iphone-ios";
      pkgs = pkgsCross.iphone32-simulator;
    };
    iphone64 = targetFor pkgsCross.iphone64;
    iphone64-simulator = targetFor pkgsCross.iphone64-simulator;
    android-armv7a = {
      triple = "armv7-linux-androideabi";
      pkgs = pkgsCross.armv7a-android-prebuilt;
    };
    host = fillTarget ((targetCompat.${stdenv.hostPlatform.config} or {
      triple = stdenv.hostPlatform.config;
    }) // {
      inherit pkgs stdenv;
    });
  };
  targets' = targets;
  shell = makeOverridable ({ channel, target ? targets'.host, targets ? [], extensions ? rustExtensions } @ args: let
    args' = builtins.removeAttrs args [ "channel" "target" "targets" "extensions" ];
    target' = fillTarget (if isString target then { triple = target; } else target);
    isCross = target'.stdenv.hostPlatform != pkgs.hostPlatform;
    mkShell' = if isCross then target'.pkgs.mkShell else mkShell;
    targets' = map (triple: if isString triple then { inherit triple; } else triple) targets;
    allTargets = map fillTarget targets' ++ [ target' ];
    ch = channel.override {
      inherit extensions;
      targets = map ({ triple, ... }: triple) (
        if isCross
        then allTargets
        else filter (target: target != target') allTargets
      );
    };
    rust = [ ch.rust ];
    cargoEnvVar = n: replaceStrings [ "-" ] [ "_" ] (toUpper n);
    envForTarget = target: {
      "CARGO_TARGET_${cargoEnvVar target.triple}_AR" = target.ar;
      "CARGO_TARGET_${cargoEnvVar target.triple}_LINKER" = target.linker;
      "CARGO_TARGET_${cargoEnvVar target.triple}_RUSTFLAGS" = [ "-C" "linker-flavor=${target.linkerFlavor}" ];
      # TODO: LDFLAGS = "-fuse-ld=gold" or something?
    };
  in mkShell' ({
    nativeBuildInputs = rust ++ rustTools;
  } // foldAttrList (map envForTarget allTargets)
  // optionalAttrs (isCross || args ? target) {
    CARGO_BUILD_TARGET = target'.triple;
  } // args'));
in {
  inherit channels targets rustTools rustExtensions;
  mkShell = shell;

  stable = shell { channel = channels.stable; };
  nightly = shell { channel = channels.nightly; };
}
