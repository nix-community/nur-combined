{
  inputs,
  lib,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkRenamedOptionModule;
in
{
  imports =
    # The `nixpkgs` options has been moved into perSystem,
    # so that it can be customized in a per-system matter.
    [
      (mkRenamedOptionModule
        [ "nixpkgs" ]
        [
          "perSystem"
          "nixpkgs"
        ]
      )
    ];
  options.perSystem = mkPerSystemOption (
    { config, system, ... }:
    let
      cfg = config.nixpkgs;
    in
    {
      _file = ./nixpkgs.nix;
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/default.nix
      options.nixpkgs = {
        path = lib.mkOption {
          type = lib.types.path;
          default = inputs.nixpkgs;
          defaultText = "inputs.nixpkgs";
          description = ''
            Path to nixpkgs to be imported.
          '';
        };
        localSystem = lib.mkOption {
          type = lib.types.attrs;
          default = {
            inherit system;
          };
          description = ''
            The system packages will be built on.
          '';
        };
        crossSystem = lib.mkOption {
          type = with lib.types; nullOr attrs;
          default = null;
          description = ''
            The system packages will ultimately be run on.
          '';
        };
        config = lib.mkOption {
          type = with lib.types; attrsOf raw;
          default = { };
          description = ''
            Allow a configuration attribute set to be passed in as an argument.
          '';
        };
        overlays = lib.mkOption {
          type = with lib.types; listOf raw;
          default = [ ];
          description = ''
            List of overlays layers used to extend Nixpkgs.
          '';
        };
        crossOverlays = lib.mkOption {
          type = with lib.types; listOf raw;
          default = [ ];
          description = ''
            List of overlays to apply to target packages only.
          '';
        };
      };

      config = {
        _module.args.pkgs = import cfg.path {
          inherit (cfg)
            localSystem
            crossSystem
            config
            overlays
            crossOverlays
            ;
        };
      };
    }
  );
}
