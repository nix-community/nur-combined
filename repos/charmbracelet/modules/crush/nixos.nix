{
  config,
  lib,
  pkgs,
  ...
}: let
  crushOptions = import ./options.nix {inherit lib;};
in {
  options.programs.crush = {
    enable = lib.mkEnableOption "Enable crush";
    settings = crushOptions;
  };

  config = lib.mkIf config.programs.crush.enable {
    environment.systemPackages = [(pkgs.callPackage ../../pkgs/crush {})];
    environment.etc."crush/crush.json" = lib.mkIf (config.programs.crush.settings != {}) {
      text = builtins.toJSON config.programs.crush.settings;
      mode = "0644";
    };
  };
}
