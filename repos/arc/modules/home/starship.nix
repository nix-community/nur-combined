{ config, lib, pkgs, ... }: with lib; let
  cfg = config.programs.starship;
in {
  options.programs.starship = {
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };
  config.xdg.configFile."starship.toml" = mkIf (cfg.enable && cfg.extraConfig != "") {
    source = mkForce (pkgs.runCommand "starship-config" {
      nativeBuildInputs = singleton pkgs.buildPackages.remarshal;
      value = builtins.toJSON cfg.settings;
      inherit (cfg) extraConfig;
      passAsFile = [ "value" "extraConfig" ];
    } ''
      json2toml $valuePath $out
      cat $extraConfigPath >> $out
    '');
  };
}
