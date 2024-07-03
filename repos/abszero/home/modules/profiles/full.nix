{
  imports = [ ./base.nix ];

  abszero = {
    services.gpg-agent.enable = true;
    programs = {
      btop.enable = true;
      carapace.enable = true;
      direnv.enable = true;
      dotdrop.enable = true;
      firefox.enable = true;
      fish = {
        enable = true;
        enableNushellIntegration = true;
      };
      foot.enable = true;
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
    nf = "neofetch";
    nvl = "~/src/lightnovel.sh/lightnovel.sh";
    zz = "z -";
  };

  services.arrpc.enable = true;

  gtk.enable = true;

  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = true;
    };
    fzf.enable = true;
    helix.enable = true;
    nix-index-database.comma.enable = true;
    yazi.enable = true;
  };
}
