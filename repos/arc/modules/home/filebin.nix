{ pkgs, config, lib, ... }: with lib; let
  cfg = config.programs.filebin;
in {
  options.programs.filebin = {
    enable = mkEnableOption "filebin path monitor";

    config = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    extraConfig = mkOption {
      type = types.string;
      default = "";
    };
  };

  config.home.packages = mkIf cfg.enable [pkgs.arc'private.filebin];
  config.xdg.configFile."filebin/config".text = ''
    ${concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=${v}") cfg.config)}
    ${cfg.extraConfig}
  '';
}
