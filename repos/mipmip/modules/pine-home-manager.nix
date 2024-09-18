{ pkgs, home-manager, ... }:
{
  imports = [
    home-manager.nixosModule
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.pim = {
    home.stateVersion = "21.11";
    home.username = "pim";
    home.homeDirectory = "/home/pim";

    programs = {
      home-manager.enable = true;
      firefox.enable = true;
      git.enable = true;
    };

    # a few useful packages to start with
    home.packages = with pkgs; [
      # useful CLI/admin tools to have during setup
      fatresize
      gptfdisk
      networkmanager
      sudo
      vim
      wget
      tmux

      # it's good to have a variety of terminals (x11, Qt, GTK) to handle more failures
      xterm
      plasma5Packages.konsole
      gnome.gnome-terminal
    ];
  };
}
