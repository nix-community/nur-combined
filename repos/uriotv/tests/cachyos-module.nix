{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) lib;
  fakeKernelPackages = { kernel = "pinned-cachyos-bore-x86_64-v3-non-lto"; };
  module = (import ../modules/cachyos-kernel.nix {
    defaultKernelPackages = fakeKernelPackages;
  });
  evaluate = extraModules: lib.evalModules {
    modules = [
      ({ ... }: {
        options.boot.kernelPackages = lib.mkOption {
          type = lib.types.attrs;
          default = { kernel = "stock"; };
        };
        options.nix.settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };
        options.assertions = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [ ];
        };
      })
      module
    ] ++ extraModules;
    specialArgs = { inherit pkgs; };
  };
  disabled = evaluate [ ];
  enabled = evaluate [ { boot.cachyos = { enable = true; cpuSupportsV3 = true; }; } ];
  overriddenPackages = { kernel = "custom-kernel"; };
  overridden = evaluate [ { boot.cachyos = {
    enable = true;
    cpuSupportsV3 = true;
    kernelPackages = overriddenPackages;
  }; } ];
  noCache = evaluate [ { boot.cachyos = {
    enable = true;
    cpuSupportsV3 = true;
    cache.enable = false;
  }; } ];
  wrongArchPkgs = pkgs // {
    stdenv = pkgs.stdenv // {
      hostPlatform = pkgs.stdenv.hostPlatform // { system = "aarch64-linux"; };
    };
  };
  wrongArch = lib.evalModules {
    modules = [
      ({ ... }: {
        options.boot.kernelPackages = lib.mkOption { type = lib.types.attrs; default = { }; };
        options.nix.settings = lib.mkOption { type = lib.types.attrs; default = { }; };
        options.assertions = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = [ ]; };
      })
      module
      { boot.cachyos = { enable = true; cpuSupportsV3 = true; }; }
    ];
    specialArgs = { pkgs = wrongArchPkgs; };
  };
  unacknowledged = evaluate [ { boot.cachyos.enable = true; } ];
  hasFailure = evaluated: !(builtins.all (x: x.assertion) evaluated.config.assertions);
in
assert disabled.config.boot.kernelPackages.kernel == "stock";
assert disabled.config.nix.settings == { };
assert enabled.config.boot.kernelPackages == fakeKernelPackages;
assert enabled.config.nix.settings.substituters == [ "https://uriotv.cachix.org" ];
assert enabled.config.nix.settings.trusted-public-keys == [
  "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI="
];
assert overridden.config.boot.kernelPackages == overriddenPackages;
assert noCache.config.boot.kernelPackages == fakeKernelPackages;
assert noCache.config.nix.settings == { };
assert hasFailure wrongArch;
assert hasFailure unacknowledged;
true
