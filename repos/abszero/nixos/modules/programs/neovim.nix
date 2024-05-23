{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.neovim;
in

{
  options.abszero.programs.neovim.enable = mkEnableOption "Neovim";

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      withNodeJs = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
    environment.systemPackages = with pkgs; [
      neovide
      clang # C compiler
      wl-clipboard # Clipboard support
      tree-sitter # For nvim-treesitter
      ripgrep # For Telescope
      nodePackages.prettier # For null-ls
    ];
  };
}
