{ ... }:
# To set up Alacritty to start with Tmux, use the modules from nix/modules/home-manager/alacritty-tmux.nix
{
  programs = {
    tmux.enable = true;
  };
}
