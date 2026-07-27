{ config, options, lib, pkgs, ... }: with lib; let
  cfg = config.programs.starship;
  configFile = mkIf (cfg.enable && cfg.extraConfig != "") {
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
in {
  options.programs.starship = {
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };
  config = if options.programs.starship ? configPath then {
    home.file.${cfg.configPath} = configFile;
  } else {
    xdg.configFile."starship.toml" = configFile;
  };
}
