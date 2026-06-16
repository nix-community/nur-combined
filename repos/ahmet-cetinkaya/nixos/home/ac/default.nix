{...}: {
  imports = [
    ./../../modules/configs/agent-ctrl.nix
    ./../../modules/configs/fastfetch.nix
    ./../../modules/configs/kde.nix
    ./../../modules/configs/kitty.nix
    ./../../modules/configs/konsave.nix
    ./../../modules/configs/neovim.nix
    ./../../modules/configs/starship.nix
    ./../../modules/configs/vesktop.nix
    ./../../modules/configs/vscodium.nix
    ./../../modules/configs/zed.nix
    ./../../modules/configs/zsh.nix
  ];

  home = {
    username = "ac";
    homeDirectory = "/home/ac";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "ahmet-cetinkaya";
        email = "ahmetcetinkaya@tutamail.com";
      };
    };
  };
}
