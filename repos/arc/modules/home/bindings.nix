{ commonRoot, pkgs, nixosConfig, config, options, lib, ... }: with lib; let
  cfg = config.networking;
  arc'lib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arc'lib.unmerged;
  hasOsBindings = config.nixos.hasSettings && nixosConfig ? networking.bindings;
  hasCommonRoot = (builtins.tryEval (commonRoot ? tag)).value;
  addCommonRoot = optional hasCommonRoot commonRoot.tag;
in {
  options = {
    networking = {
      bindings = mkOption {
        type = unmerged.types.attrs;
        default = { };
      };
      domains = mkOption {
        type = unmerged.types.attrs;
        default = { };
      };
      evalBindings = mkOption {
        type = types.attrsOf (types.submodule ([
          ../misc/binding.nix
        ] ++ addCommonRoot));
        internal = true;
      };
      evalDomains = mkOption {
        type = types.attrsOf (types.submodule ([
          ../misc/domain.nix
          ({ ... }: {
            config._module.args = {
              inherit pkgs nixosConfig;
              homeConfig = config;
            };
          })
        ] ++ addCommonRoot));
        internal = true;
      };
    };
  };
  config = {
    networking.evalBindings = unmerged.mergeAttrs cfg.bindings;
    networking.evalDomains = unmerged.mergeAttrs cfg.domains;
    nixos.settings.networking = mapAttrs (_: unmerged.mergeAttrs) {
      inherit (cfg) bindings domains;
    };
    _module.args.networking = {
      bindings = if hasOsBindings
        then nixosConfig.networking.bindings
        else cfg.evalBindings;
      domains = if hasOsBindings
        then nixosConfig.networking.domains
        else cfg.evalDomains;
    };
  };
}
