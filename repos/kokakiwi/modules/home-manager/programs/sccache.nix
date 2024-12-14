{ config, pkgs, lib, ... }:
let
  defaultPackage = pkgs.callPackage ../../../pkgs/applications/sccache { };

  cfg = config.programs.sccache;

  configFormat = pkgs.formats.toml { };
in {
  options.programs.sccache = with lib; {
    enable = mkEnableOption "sccache client";

    package = mkOption {
      type = types.package;
      default = defaultPackage;
    };

    settings = mkOption {
      type = configFormat.type;
      default = { };
    };
  };

  config = with lib; mkIf cfg.enable (let
    package = cfg.package.override {
      enableDistClient = true;
    };
  in {
    home.packages = [ package ];
  });
}
