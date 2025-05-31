{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      iosevka
      nerd-fonts.fantasque-sans-mono
      noto-fonts-emoji
      sarasa-gothic
      source-han-mono
      source-han-sans
      source-han-serif
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "FantasqueSansM Nerd Font Mono" "Source Han Serif SC" ];
        sansSerif = [ "FantasqueSansM Nerd Font Mono" "Source Han Sans SC" ];
        monospace = [ "FantasqueSansM Nerd Font Mono" "Source Han Mono SC" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
