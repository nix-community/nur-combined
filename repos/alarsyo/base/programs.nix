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
      tree
      wget
      pciutils
      usbutils
      # development
      git
      git-crypt
      git-lfs
      gnumake
      gnupg
      python3
      shellcheck
      vim
      # terminal utilities
      htop
      jq
      unzip
      zip
      ;
  };
}
