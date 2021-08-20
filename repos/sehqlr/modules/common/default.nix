{ config, home-manager, lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;

  environment = {
    systemPackages = with pkgs; [ commonsCompress ];
    pathsToLink = [ "/share/zsh" ];
  };

  fonts = {
      enableDefaultFonts = true;
      fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
      fontconfig.enable = true;
  };

  home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.sam = import ./hm.nix { inherit config home-manager lib pkgs; };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  nix = {
      autoOptimiseStore = true;
      gc.automatic = true;
      package = pkgs.nixUnstable;
      trustedUsers = [ "root" "sam" ];
  };

  nixpkgs.config = import ./nixpkgs-config.nix;

  services.ipfs = {
    enable = true;
    enableGC = true;
  };

  system = {
      autoUpgrade.enable = true;
      copySystemConfiguration = true;
  };

  users.users.sam = {
    description = "Sam Hatfield <hey@samhatfield.me>";
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
