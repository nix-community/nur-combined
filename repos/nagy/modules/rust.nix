{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.rust;
in
{
  imports = [ ./shortcommands.nix ];

  options.nagy.rust = {
    enable = lib.mkEnableOption "rust config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.rustc
      pkgs.rustfmt
      pkgs.cargo
      pkgs.cargo-bloat
      pkgs.rust-analyzer
      pkgs.rust-script
      pkgs.cargo-modules
      pkgs.cargo-cache

      # convenience
      pkgs.cargo-watch
      pkgs.cargo-info
      pkgs.cargo-sort

      # wasm
      pkgs.binaryen
      pkgs.cargo-component
    ];

    # # Maybe this is better done via a config file.
    # environment.variables = {
    #   CARGO_ALIAS_r = "run --quiet";
    #   CARGO_ALIAS_rr = "run --release --quiet";
    #   CARGO_ALIAS_b = "build";
    #   CARGO_ALIAS_br = "build --release";
    #   CARGO_ALIAS_t = "test";
    #   CARGO_ALIAS_tr = "test --release";
    # };

    nagy.shortcommands.commands = {
      # may also be done via aliases
      # https://doc.rust-lang.org/cargo/reference/config.html#alias
      C = [ "cargo" ];
      Cr = [
        "cargo"
        "run"
        "--quiet"
      ];
      Crr = [
        "cargo"
        "run"
        "--release"
        "--quiet"
      ];
      Cb = [
        "cargo"
        "build"
      ];
      Cbr = [
        "cargo"
        "build"
        "--release"
      ];
      Ct = [
        "cargo"
        "test"
      ];
      Ctr = [
        "cargo"
        "test"
        "--release"
      ];
      Cx = [
        "cargo"
        "clean"
      ];
    };

    environment.sessionVariables.CARGO_TARGET_WASM32_WASIP1_RUNNER = "${pkgs.wasmtime}/bin/wasmtime run";
  };
}
