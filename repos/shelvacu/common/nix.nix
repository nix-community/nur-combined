{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  caches = builtins.attrValues config.vacu.nix.caches;
  enabledCaches = builtins.filter (c: c.enable) caches;
in
{
  options = {
    vacu.nix.caches = mkOption {
      type = types.attrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              url = mkOption { type = types.str; };
              keys = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
              enable = mkOption {
                default = true;
                type = types.bool;
              };
            };
          }
        )
      );
    };
    vacu.nix.substituterUrls = mkOption { readOnly = true; };
    vacu.nix.trustedKeys = mkOption { readOnly = true; };
  };
  config.vacu.nix.substituterUrls = map (c: c.url) enabledCaches;
  config.vacu.nix.trustedKeys = builtins.concatMap (c: c.keys) enabledCaches;
}
