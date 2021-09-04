{ pkgs, config, lib, ... }: let
  cfg = config.base16;
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
      schemeName = mkOption {
        type = types.str;
        default = cfg.defaultSchemeName;
      };
      scheme = mkOption {
        type = with types; coercedTo str (name: cfg.schemes.${name}) attrs;
        default = cfg.schemes.${cfg.console.schemeName};
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
      colors = map (b: b.rgb) (sort (a: b: a.ansiIndex < b.ansiIndex) (attrValues (getAttrs base16.names cfg.console.scheme)));
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
