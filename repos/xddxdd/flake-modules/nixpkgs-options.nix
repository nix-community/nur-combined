{
  inputs,
  lib,
  flake-parts-lib,
  ...
}:
let
  instanceOptions = _: {
    options = {
      sourceInput = lib.mkOption {
        description = "Source nixpkgs input";
        default = inputs.nixpkgs;
      };
      allowUnfree = lib.mkOption {
        type = lib.types.bool;
        description = "Enable unfree packages";
        default = true;
      };
      patches = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        description = "List of patches to apply to nixpkgs";
        default = [ ];
      };
      overlays = lib.mkOption {
        # Do not set type here, or infinite recursion will happen
        description = "List of overlays to apply to nixpkgs";
        default = [ ];
      };
      permittedInsecurePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of insecure packages to be allowed";
        default = [ ];
      };
      allowInsecurePredicate = lib.mkOption {
        type = lib.types.anything;
        description = "Predicate to check if insecure package is allowed";
        default = null;
      };
      settings = lib.mkOption {
        type = lib.types.attrs;
        description = "Extra attributes to pass to nixpkgs.config";
        default = { };
      };
    };
  };
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      lib,
      system,
      config,
      ...
    }:
    {
      options.nixpkgs-options = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule instanceOptions);
        default = { };
      };

      config = rec {
        _module.args = lib.mapAttrs (
          n: v:
          lib.mkForce (
            import packages."${n}-patched" {
              inherit system;
              config =
                {
                  inherit (v) allowUnfree permittedInsecurePackages;
                }
                // (lib.optionalAttrs (v.allowInsecurePredicate != null) {
                  inherit (v) allowInsecurePredicate;
                })
                // v.settings;
              inherit (v) overlays;
            }
          )
        ) config.nixpkgs-options;

        packages = lib.mapAttrs' (
          n: v:
          let
            inherit ((import inputs.nixpkgs { inherit system; })) applyPatches;
          in
          lib.nameValuePair "${n}-patched" (applyPatches {
            name = "${n}-patched";
            src = builtins.toString v.sourceInput;
            inherit (v) patches;
          })
        ) config.nixpkgs-options;
      };
    }
  );
}
