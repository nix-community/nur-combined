{ config, pkgs, lib, ... }: with pkgs.lib; with lib; let
  cfg = config.programs.rustfmt;
in {
  options.programs.rustfmt = {
    enable = mkEnableOption "rustfmt";
    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.rustfmt;
      defaultText = "pkgs.rustfmt";
    };
    config = mkOption {
      type = types.attrs;
      default = {};
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;

    xdg.configFile = mkIf (cfg.config != {} || cfg.extraConfig != "") {
      "rustfmt/rustfmt.toml".text = ''
        ${toTOML cfg.config}
        ${cfg.extraConfig}
      '';
    };
  };
}
