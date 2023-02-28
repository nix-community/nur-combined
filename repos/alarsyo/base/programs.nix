{pkgs, ...}: {
  programs = {
    fish.enable = true;
    less.enable = true;
    mosh.enable = true;

    # setcap wrapper for network permissions
    bandwhich.enable = true;
  };

  services.openssh = {
    passwordAuthentication = false;
    permitRootLogin = "no";
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      # shell usage
      
      fd
      file
      ripgrep
      sd
      tmux
      tokei
      tree
      wget
      jq
      pciutils
      usbutils
      # development
      
      alejandra
      git
      git-crypt
      git-lfs
      gnumake
      gnupg
      kakoune
      pinentry-qt
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
