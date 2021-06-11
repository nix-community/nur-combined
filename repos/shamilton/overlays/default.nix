{ selfnur }:
{
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  alacritty = import ./alacritty { inherit (selfnur) patched-alacritty; };
  tabbed = import ./tabbed { inherit (selfnur) patched-tabbed; };
  rofi = import ./rofi { inherit (selfnur) patched-rofi; };
}

