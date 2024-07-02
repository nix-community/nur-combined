{ inputs, lib, config, ... }: {
  options.nixpkgs-options = {
    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      description = "Enable unfree packages";
      default = true;
    };
    exportPatchedNixpkgs = lib.mkOption {
      type = lib.types.bool;
      description = "Export patched nixpkgs as packages.nixpkgs-patched";
      default = false;
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

  config.perSystem = { system, ... }:
    let
      nixpkgs-patched =
        (import inputs.nixpkgs { inherit system; }).applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs;
          inherit (config.nixpkgs-options) patches;
        };
    in {
      _module.args.pkgs = import nixpkgs-patched {
        inherit system;
        config = {
          inherit (config.nixpkgs-options) allowUnfree;
          inherit (config.nixpkgs-options) permittedInsecurePackages;
        };
        inherit (config.nixpkgs-options) overlays;
      };
    } // lib.optionalAttrs config.nixpkgs-options.exportPatchedNixpkgs {
      packages.nixpkgs-patched = nixpkgs-patched;
    };
}
