{ pkgs, config, lib, ... }: let
  cfg = config.base16;
  consoleShell = (config.lib.arc.base16.schemeFor cfg.console.scheme).shell.override { inherit (cfg.console) ansiCompatibility; };
  makeColorCS = n: value: "\\e]P${lib.toHexUpper or arc.lib.toHexUpper n}${value}";
  arc = import ../../canon.nix { inherit pkgs; };
in with lib; {
  options.console.getty = {
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
      getty = {
        enable = mkEnableOption "getty login colours" // {
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
      getty = mkIf cfg.console.getty.enable {
        greetingPrefix = mkBefore ((lib.concatImap0Strings or arc.lib.concatImap0Strings) makeColorCS config.console.colors);
        greeting = mkDefault ''<<< Welcome to NixOS ${config.system.nixos.label} (\m) - \l >>>'';
      };
    };
    services.getty = mkIf cfg.console.getty.enable {
      greetingLine = "${config.console.getty.greetingPrefix}${config.console.getty.greeting}";
    };
  };
}
