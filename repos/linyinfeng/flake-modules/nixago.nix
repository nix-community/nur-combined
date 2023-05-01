{ inputs, lib, flake-parts-lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkPerSystemOption;

  nixagoConfig = { defaultEngine }:
    { ... }: {
      options = {
        data = mkOption {
          type = types.anything;
          description = ''
            Data of the configuration file.
          '';
        };
        output = mkOption {
          type = types.str;
          description = ''
            Name of output file.
          '';
        };
        format = mkOption {
          type = types.str;
          description = ''
            Format of the configuration file.
          '';
        };
        engine = mkOption {
          type = types.unspecified;
          default = defaultEngine;
          defaultText = "inputs.nixago.engines.\${system}.nix { }";
          description = ''
            Engine used to generate configuration file.
          '';
        };
      };
    };
in
{
  options.perSystem = mkPerSystemOption ({ config, system, ... }: {
    _file = ./nixago.nix;
    options = {
      nixago = {
        configs = mkOption {
          type = with types; listOf (submodule (nixagoConfig {
            defaultEngine = inputs.nixago.engines.${system}.nix { };
          }));
          default = [ ];
          description = ''
            List of nixago configurations.
          '';
        };
        shellHook = mkOption {
          type = types.str;
          default = (inputs.nixago.lib.${system}.makeAll config.nixago.configs).shellHook;
          defaultText = "(inputs.nixago.lib.\${system}.makeAll config.nixago.configs).shellHook";
          readOnly = true;
          description = ''
            Shell hook string of nixago.
          '';
        };
      };
    };
  });
}
