{ pkgs
, tmux-pkg ? pkgs.tmux 
, terminal ? "screen-256color"
}:

{
  programs.tmux = {
    enable = true;
    package = tmux-pkg;
    clock24 = true;
    # Neovim related (https://github.com/neovim/neovim/wiki/FAQ#esc-in-tmux-or-gnu-screen-is-delayed)
    escapeTime = 10;
    terminal = terminal;
    extraConfig = ''
      set-option -sa terminal-overrides ',${terminal}:RGB'
    '';
  };
}
