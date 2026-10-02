{
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;

  default = import ./firefox-addons.nix;
  firefox-addons = import ./firefox-addons.nix;
}
