{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.font-check ];
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      dejavu_fonts
      lxgw-neoxihei
      lxgw-wenkai
      nerd-fonts.fantasque-sans-mono
      noto-fonts-color-emoji
    ];
  };
}
