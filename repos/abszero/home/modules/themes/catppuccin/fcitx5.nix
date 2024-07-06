{
  imports = [
    ./catppuccin.nix
    ./fonts.nix
  ];

  # Complementary to catppuccin/nix
  i18n.inputMethod.fcitx5.catppuccin.enable = true;

  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Vertical Candidate List=True
    Font="Noto Sans 13"
    MenuFont="Open Sans 13"
    TrayFont="Open Sans 13"
    TrayOutlineColor=#ffffff00
    TrayTextColor=#000000
    PreferTextIcon=True
  '';
}
