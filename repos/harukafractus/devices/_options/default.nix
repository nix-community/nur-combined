{ pkgs, ... }: {
  # nix-darwin requires zsh to work
  programs.zsh.enable = true;

  # Enable flakes and hard links
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    show-trace = true;
    trusted-users = [ "@admin" "@wheel" "root" ];
  };

  # Essential packages for all systems
  environment.systemPackages = with pkgs; [
    android-tools
    htop
    git
    curl
    coreutils-full
    util-linux
    smartmontools
    pciutils
    wget
    bat
    unar
  ];
}