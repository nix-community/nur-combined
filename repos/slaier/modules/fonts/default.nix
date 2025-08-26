{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fantasque-sans-mono
      noto-fonts-emoji
      vista-fonts-chs
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "FantasqueSansM Nerd Font Mono" "Microsoft YaHei" ];
        sansSerif = [ "FantasqueSansM Nerd Font Mono" "Microsoft YaHei" ];
        monospace = [ "FantasqueSansM Nerd Font Mono" "Microsoft YaHei" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
