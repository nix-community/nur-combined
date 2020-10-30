{ config, pkgs, ... }: {
  environment.pathsToLink = [ "/share/zsh" ];
  programs.sway.enable = true;
  users.users.sam = {
      description = "Sam Hatfield <hey@samhatfield.me>";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      isNormalUser = true;
      shell = pkgs.zsh;
  };
}
