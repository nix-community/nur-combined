isNixos: { pkgs, config, lib, ... }: with lib; let
  cfg = config.base16;
in {
  options.base16 = {
    schemes = mkOption {
      type = types.listOf types.str;
      example = [ "tomorrow.tomorrow-night" ];
      default = [];
    };

    alias = {
      default = mkOption {
        type = types.str;
        defaultText = "head config.home.base16.schemes";
        default = if length cfg.schemes > 0 then head cfg.schemes else throw "base16.alias.default unset";
      };
      dark = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      light = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

    terminal = {
      ansiCompatibility = mkEnableOption "bright colours mimic their normal counterparts" // { default = true; };
    };

    shell = {
      enable = mkEnableOption "base16 theme application from your shell";
    };
  };

  config = mkMerge (singleton {
    lib.arc.base16 = {
      schemeFor = scheme: let
        path' = splitString "." scheme;
        path = if length path' == 1 then path' ++ [ "default" ] else path';
      in if isString scheme then getAttrFromPath path pkgs.base16.scheme else scheme;
      shellScriptFor = scheme: let
        scheme' = config.lib.arc.base16.schemeFor scheme;
      in pkgs.writeText "base16-${scheme'.scheme-name}.sh" scheme'.shell.script;
    };
  } ++ optional (!isNixos) {
    programs.zsh = mkIf (config.programs.zsh.enable && cfg.shell.enable) {
      initExtra = ''
        source ${config.lib.arc.base16.shellScriptFor cfg.alias.default}
      '';
    };
    programs.bash = mkIf (config.programs.bash.enable && cfg.shell.enable) {
      initExtra = ''
        source ${config.lib.arc.base16.shellScriptFor cfg.alias.default}
      '';
    };
  });
}
