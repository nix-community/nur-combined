{ inputs, config, ... }:

let inherit (config.lib.catppuccin) getVariant; in

{
  imports = [
    ./_options.nix
    ./fonts.nix
  ];

  xdg = {
    configFile."fcitx5/conf/classicui.conf".text = ''
      Theme=catppuccin-${getVariant}
      Vertical Candidate List=True
      Font="Noto Sans 13"
      MenuFont="Open Sans 13"
      TrayFont="Open Sans 13"
      TrayOutlineColor=#ffffff00
      TrayTextColor=#000000
      PreferTextIcon=True
    '';
    dataFile."fcitx5/themes/catppuccin-${getVariant}".source =
      "${inputs.catppuccin-fcitx5}/src/catppuccin-${getVariant}";
  };
}
