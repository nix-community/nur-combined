{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.crush;
in {
  options = import ./options { inherit pkgs; };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.etc."crush/crush.json" = lib.mkIf (cfg.settings != {}) {
      text = builtins.toJSON cfg.settings;
      mode = "0644";
    };
  };
}
