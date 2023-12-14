{pkgs, ...}: {
  programs = {
    fish.enable = true;
    less.enable = true;
    mosh.enable = true;
    tmux.enable = true;

    # setcap wrapper for network permissions
    bandwhich.enable = true;
  };

  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = true;
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      # shell usage
      
      bat
      fd
      file
      ripgrep
      sd
      tokei
      tree
      wget
      jq
      pciutils
      usbutils
      # development
      
      agenix
      alejandra
      git
      git-crypt
      git-lfs
      gnumake
      gnupg
      pinentry-qt
      python3
      vim
      # terminal utilities
      
      dogdns
      du-dust
      htop
      ldns # drill
      unzip
      zip
      ;
  };
}
