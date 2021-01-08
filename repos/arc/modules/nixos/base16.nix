{ pkgs, config, lib, ... }: with pkgs.lib; with lib; let
  cfg = config.base16;
  consoleShell = (config.lib.arc.base16.schemeFor cfg.console.scheme).shell.override { inherit (cfg.console) ansiCompatibility; };
  makeColorCS = n: value: "\\e]P${toHexUpper n}${value}";
in {
  options.console.mingetty = {
    greetingPrefix = mkOption {
      type = types.separatedString "";
      default = "";
    };
    greeting = mkOption {
      type = types.str;
    };
  };
  options.base16 = {
    console = {
      enable = mkEnableOption "base16 Linux console colours";
      scheme = mkOption {
        type = types.str;
        default = cfg.alias.default;
      };
      mingetty = {
        enable = mkEnableOption "migetty login colours" // {
          default = cfg.console.enable;
          defaultText = "true";
        };
      };
      ansiCompatibility = mkEnableOption "bright colours mimic their normal counterparts" // { default = cfg.terminal.ansiCompatibility; };
    };
  };
  config = {
    console = mkIf cfg.console.enable {
      colors = map (v: v.hex.rgb) consoleShell.colours16;
      mingetty = mkIf cfg.console.mingetty.enable {
        greetingPrefix = mkBefore (concatImap0Strings makeColorCS config.console.colors);
        greeting = mkDefault ''<<< Welcome to NixOS ${config.system.nixos.label} (\m) - \l >>>'';
      };
    };
    services.mingetty = mkIf cfg.console.mingetty.enable {
      greetingLine = "${config.console.mingetty.greetingPrefix}${config.console.mingetty.greeting}";
    };
  };
}
