{ config, pkgs, lib, ... }: with lib; let
  cfg = config.home.shell;
  shellFunctions = lib.concatStringsSep "\n" (lib.mapAttrsToList (fn: body: ''
    function ${fn}() {
      ${body}
    }
  '') cfg.functions);
in {
  options.home.shell = {
    functions = mkOption {
      type = types.attrsOf types.lines;
      default = { };
    };
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
  };
  options.programs.bash.localVariables = mkOption {
    type = types.attrsOf types.str;
    default = { };
  };

  config.programs.zsh = mkIf config.programs.zsh.enable {
    shellAliases = cfg.aliases;
    initExtra = shellFunctions;
  };
  config.programs.bash = mkIf config.programs.bash.enable {
    shellAliases = cfg.aliases;
    initExtra = ''
      ${config.lib.zsh.defineAll config.programs.bash.localVariables}
      ${shellFunctions}
    '';
  };
}
