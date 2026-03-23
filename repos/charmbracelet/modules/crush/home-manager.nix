{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.crush;
  charmLib = import ../../lib { inherit pkgs; };
in {
  options = import ./options {inherit pkgs;};

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file.".config/crush/crush.json" = lib.mkIf (cfg.settings != {}) {
      source = charmLib.toCleanJSON cfg.settings;
    };
  };
}
