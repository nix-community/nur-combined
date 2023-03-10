{ config, inputs, flake-parts-lib, lib, ... }:

let cfg = config.nixpkgs.config; in
{
  options.nixpkgs.config = lib.mkOption {
    type = with lib.types; attrsOf raw;
    default = { };
  };
  config = {
    perSystem = { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = cfg;
        };
      };
  };
}
