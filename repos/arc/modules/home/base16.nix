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
      schemeForAlias = mapAttrs (_: config.lib.arc.base16.schemeFor) config.base16.alias;
      shellScriptFor = scheme: let
        scheme' = config.lib.arc.base16.schemeFor scheme;
      in pkgs.writeText "base16-${scheme'.scheme-slug}.sh" scheme'.shell.script;
      shellScriptForAlias = mapAttrs (_: config.lib.arc.base16.shellScriptFor) config.base16.alias;
    };
  } ++ optional (!isNixos) {
    programs.zsh = mkIf (config.programs.zsh.enable && cfg.shell.enable) {
      initExtra = ''
        source ${config.lib.arc.base16.shellScriptForAlias.default}
      '';
    };
    programs.bash = mkIf (config.programs.bash.enable && cfg.shell.enable) {
      initExtra = ''
        source ${config.lib.arc.base16.shellScriptForAlias.default}
      '';
    };
    programs.vim = mkIf (config.programs.vim.enable && cfg.shell.enable) {
      extraConfig = mkBefore (optionalString cfg.terminal.ansiCompatibility ''
        let base16colorspace=256
      '' + (let
        colorscheme = "base16-${config.lib.arc.base16.schemeForAlias.default.scheme-slug}";
      in optionalString (cfg.schemes != []) ''
        if !exists('g:colors_name') || g:colors_name != 'base16-${colorscheme}'
          colorscheme ${colorscheme}
        endif
      '')
      );
    };
  });
}
