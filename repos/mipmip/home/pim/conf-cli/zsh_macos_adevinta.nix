{ config, pkgs, ... }:

{
  programs.zsh = {

    shellAliases.smugsadv = "smug start nixos && tn legacy && tn common";

    sessionVariables = {
      LC_CTYPE = "en_US.UTF-8";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      theme = "pim";
      custom = "$HOME/.ohmyzsh-pim";
      plugins=["git kubectl terraform aws"];
    };

    initExtra = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';

  };
}
