{ pkgs, ... }: {
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FantasqueSansMono"
        ];
      })
      noto-fonts-emoji
      source-han-mono
      source-han-sans
      source-han-serif
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "FantasqueSansMono Nerd Font Mono" "Source Han Serif SC" ];
        sansSerif = [ "FantasqueSansMono Nerd Font Mono" "Source Han Sans SC" ];
        monospace = [ "FantasqueSansMono Nerd Font Mono" "Source Han Mono SC" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
