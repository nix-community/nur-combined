{ config, lib, ... }:
let
  cfg = config.my.home.atuin;
in
{
  options.my.home.atuin = with lib; {
    enable = my.mkDisableOption "atuin configuration";
  };

  config = {
    programs.atuin = {
      enable = true;

      flags = [
        # I *despise* this hijacking of the up key, even though I use Ctrl-p
        "--disable-up-arrow"
      ];

      settings = {
        # The package is managed by Nix
        update_check = false;
        # I don't care for the fancy display
        style = "compact";
        # Get closer to fzf's fuzzy search
        search_mode = "skim";
        # Show long command lines at the bottom
        show_preview = true;
      };
    };
  };
}
