{
  inputs,
  lib,
  config,
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
    };
  };
in
{
  options.nixpkgs-options = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule instanceOptions);
    default = { };
  };

  config.perSystem =
    { system, ... }:
    rec {
      _module.args = lib.mapAttrs (
        n: v:
        lib.mkForce (
          import packages."${n}-patched" {
            inherit system;
            config = {
              inherit (v) allowUnfree permittedInsecurePackages;
            };
            inherit (v) overlays;
          }
        )
      ) config.nixpkgs-options;

      packages = lib.mapAttrs' (
        n: v:
        lib.nameValuePair "${n}-patched" (
          (import v.sourceInput { inherit system; }).applyPatches {
            name = "nixpkgs-patched";
            src = builtins.toString v.sourceInput;
            inherit (v) patches;
          }
        )
      ) config.nixpkgs-options;
    };
}
