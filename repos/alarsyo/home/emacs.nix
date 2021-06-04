{ config, lib, pkgs, ... }:
{
  options.my.home.emacs = with lib; {
    enable = mkEnableOption "Emacs daemon configuration";
  };

  config = lib.mkIf config.my.home.emacs.enable {
    home.packages = with pkgs; [
      sqlite # needed by org-roam

      # fonts used by my config
      emacs-all-the-icons-fonts
      iosevka-bin
    ];
    # make sure above fonts are discoverable
    fonts.fontconfig.enable = true;

    services.emacs = {
      enable = true;
      # generate emacsclient desktop file
      client.enable = true;
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacsPgtkGcc;
    };
  };
}
