{ config, pkgs, ... }:

{
  programs.zsh = {

    shellAliases.smugsadv = "smug start nixos && tn legacy && tn common";

    sessionVariables = {
      LC_CTYPE = "en_US.UTF-8";
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
