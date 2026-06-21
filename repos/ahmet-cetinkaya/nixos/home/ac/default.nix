{pkgs, ...}: {
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
        email = "ahmetcetinkaya.me@proton.me";
        signingKey = "E52DA6A2FA3247526E01B7010E4139BDC3163C05";
      };
      commit.gpgSign = true;
      tag.gpgSign = true;
      gpg.program = "gpg2";
    };
  };

  home.packages = with pkgs; [
    gnupg
    pinentry-tty
  ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    enableSshSupport = true;
  };
}
