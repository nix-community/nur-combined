{pkgs, ...}: {
  programs = {
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    less.enable = true;
    mosh.enable = true;
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    # setcap wrapper for network permissions
    bandwhich.enable = true;
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      # shell usage
      
      fd
      ripgrep
      sd
      tmux
      tokei
      tree
      wget
      jq
      # development
      
      alejandra
      git
      git-crypt
      git-lfs
      gnumake
      gnupg
      kakoune
      pinentry-gnome
      python3
      vim
      # terminal utilities
      
      bottom
      dogdns
      du-dust
      htop
      ldns # drill
      tealdeer
      unzip
      zip
      # nix pkgs lookup
      
      nix-index
      agenix
      cachix
      ;

    inherit
      (pkgs.llvmPackages_11)
      bintools
      clang
      ;
  };
}
