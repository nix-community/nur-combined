# Add your overlays here
#
# my-overlay = import ./my-overlay;


let
  rust-overlay = import ./rust-overlay.nix;
in
rust-overlay

