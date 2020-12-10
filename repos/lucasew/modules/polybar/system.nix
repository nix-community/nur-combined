{pkgs, ...}: {
  fonts.fonts = with pkgs; [
    siji
    noto-fonts
    noto-fonts-emoji
    fira-code
  ];
}
