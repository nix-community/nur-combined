{ pkgs, config, lib, ... }: with lib; let
  arc = pkgs.arc or (import ../../canon.nix { inherit pkgs; });
  json = lib.json or arc.lib.json;
  cfg = config.programs.screenstub;
  screenstub = pkgs.writeShellScriptBin "screenstub" ''
    exec ${cfg.package}/bin/screenstub -c ${cfg.configFile} "$@"
  '';
  settingsModule = { config, ... }: {
    freeformType = json.types.attrs;
  };
in {
  options.programs.screenstub = {
    enable = mkEnableOption "screenstub";

    package = mkOption {
      type = types.package;
      default = pkgs.screenstub or arc.packages.screenstub;
      defaultText = "pkgs.screenstub";
    };

    settings = mkOption {
      type = types.submodule settingsModule;
      default = { };
    };

    configFile = mkOption {
      type = types.path;
      default = "${pkgs.writeText "screenstub.yml" (builtins.toJSON cfg.settings)}";
      defaultText = "config.programs.screenstub.settings";
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ screenstub ];
  };
}
