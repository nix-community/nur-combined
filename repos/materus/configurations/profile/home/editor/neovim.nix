{ config, lib, pkgs, materusPkgs, ... }:
let
cfg = config.materus.profile.editor.neovim;
in
{
  options.materus.profile.editor.neovim.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableTerminal "Enable neovim with materus cfg";
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      coc.enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };
  };

}
