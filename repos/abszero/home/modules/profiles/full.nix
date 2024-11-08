{ config, lib, ... }:

let
  inherit (lib) mkDefault mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.full;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.full.enable = mkExternalEnableOption config "full profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.base.enable = true;
      i18n.inputMethod.fcitx5.enable = true;
      services.gpg-agent.enable = true;
      programs = {
        btop.enable = true;
        carapace.enable = true;
        direnv.enable = true;
        dotdrop.enable = true;
        # firefox.enable = true;
        git.enable = true;
        nushell.enable = true;
        starship.enable = true;
        thunderbird.enable = true;
        zoxide.enable = true;
      };
    };

    home.shellAliases = {
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ani = "ani-cli";
      c = "clear";
      cat = "bat";
      lns = "ln -s";
      f = "fastfetch";
      nvl = "lightnovel.sh";
    };

    services.arrpc.enable = true;

    gtk.enable = true;
    qt = {
      enable = true;
      style.name = mkDefault "kvantum";
      platformTheme.name = mkDefault "kvantum";
    };

    programs = {
      bat.enable = true;
      eza = {
        enable = true;
        git = true;
        icons = "auto";
      };
      fastfetch.enable = true;
      fzf.enable = true;
      helix.enable = true;
      nix-index-database.comma.enable = true;
      yazi.enable = true;
      zsh = {
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        enableVteIntegration = true;
      };
    };
  };
}
