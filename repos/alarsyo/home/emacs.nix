{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.my.home.emacs = {
    enable = mkEnableOption "Emacs daemon configuration";
  };

  config = mkIf config.my.home.emacs.enable {
    home.sessionPath = ["${config.xdg.configHome}/emacs/bin"];
    home.sessionVariables = {
      EDITOR = "emacsclient -t";
    };

    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        sqlite # needed by org-roam

        # fonts used by my config
        emacs-all-the-icons-fonts
        ;

      inherit
        (pkgs.nerd-fonts)
        iosevka
        ;
    };
    # make sure above fonts are discoverable
    fonts.fontconfig.enable = true;

    services.emacs = {
      enable = true;
      # generate emacsclient desktop file
      client.enable = true;
      socketActivation.enable = true;
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs30-pgtk;
      extraPackages = epkgs: [
        epkgs.vterm
        epkgs.pdf-tools
        epkgs.mu4e
        epkgs.treesit-grammars.with-all-grammars

        pkgs.lilypond
      ];
    };
  };
}
