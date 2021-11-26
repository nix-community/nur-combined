{config, pkgs, lib, self, ...}:
let
  inherit (lib) mkOption types;
  inherit (builtins) concatStringsSep attrValues mapAttrs;
  cfg = config.gc-hold;
in {
  options.gc-hold = {
    paths = mkOption {
      description = "Paths to hold for GC";
      type = types.listOf types.package;
      default = [];
    };
  };
  config = {
    environment.etc.nix-gchold.text = concatStringsSep "\n" cfg.paths;
    gc-hold.paths = attrValues (mapAttrs (k: v: v.outPath) self.inputs);
  };
}
