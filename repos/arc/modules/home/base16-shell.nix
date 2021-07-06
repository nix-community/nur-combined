{ config, pkgs, lib, ... }: with lib; let
  cfg = config.home.base16-shell;
  arc = import ../../canon.nix { inherit pkgs; };
  shellInit = ''
    BASE16_SHELL="${cfg.package}"
    if [[ -n "''${PS1-}" ]]; then
      #eval "$(${cfg.package}/profile_helper.sh)"
      #${optionalString (cfg.defaultTheme != null) ''base16_${cfg.defaultTheme}''}
      ${optionalString (cfg.defaultTheme != null) ''${pkgs.runtimeShell} $BASE16_SHELL/scripts/base16-${cfg.defaultTheme}.sh''}
    fi
  '';
in {
  options.home.base16-shell = {
    enable = mkEnableOption "base16-shell";
    defaultTheme = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.base16-shell or arc.packages.base16-shell;
      defaultText = "pkgs.base16-shell";
    };
  };
  config.programs.zsh = mkIf (config.programs.zsh.enable && cfg.enable) {
    initExtra = shellInit;
  };
  config.programs.bash = mkIf (config.programs.bash.enable && cfg.enable) {
    initExtra = shellInit;
  };
  config.programs.vim = mkIf (config.programs.vim.enable && cfg.enable) {
    extraConfig = mkBefore (''
      let base16colorspace=256
      let g:base16_shell_path="${cfg.package}/scripts/"
      if filereadable(expand("~/.vimrc_background"))
        source ~/.vimrc_background
      endif
    '' + (optionalString (cfg.defaultTheme != null) ''
      if !exists('g:colors_name') || g:colors_name != 'base16-${cfg.defaultTheme}'
        colorscheme base16-${cfg.defaultTheme}
      endif
    ''));
  };
}
