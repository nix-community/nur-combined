{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [ whatsapp-emoji-font ];
    fontconfig.defaultFonts = {
      serif = [ "Fira Code Light" ];
      sansSerif = [ "Fira Code Light" ];
      monospace = [ "Fira Code Light" ];
      emoji = [ "Apple Color Emoji" ];
    };
  };

}
