{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.atuin;
in
{
  options.my.home.atuin = with lib; {
    enable = my.mkDisableOption "atuin configuration";

    # I want the full experience by default
    package = mkPackageOption pkgs "atuin" { };

    daemon = {
      enable = my.mkDisableOption "atuin daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      inherit (cfg) package;

      daemon = lib.mkIf cfg.daemon.enable {
        enable = true;
      };

      flags = [
        # I *despise* this hijacking of the up key, even though I use Ctrl-p
        "--disable-up-arrow"
      ];

      settings = {
        # Reasonable date format
        dialect = "uk";
        # The package is managed by Nix
        update_check = false;
        # I don't care for the fancy display
        style = "compact";
        # Get closer to fzf's fuzzy search
        search_mode = "skim";
        # Show long command lines at the bottom
        show_preview = true;
        # I like being able to edit my commands
        enter_accept = false;
      };
    };
  };
}
