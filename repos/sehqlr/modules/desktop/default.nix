{ config, lib, pkgs, ... }: {
  environment = {
      systemPackages = with pkgs; [
        commonsCompress
      ];
      pathsToLink = [ "/share/zsh" ];
  };

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "FiraCode Mono" ];

  networking.networkmanager.enable = true;

  nix.trustedUsers = [ "root" "sam" ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.pulseaudio.enable = true;

  users.users.sam = {
    description = "Sam Hatfield <hey@samhatfield.me>";
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  virtualisation.podman.enable = true;
}
