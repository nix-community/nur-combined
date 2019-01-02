self: super:

{
  # Package overrides
  the-powder-toy = import ../overrides/the-powder-toy.nix super;
  update-resolv-conf = import ../overrides/update-resolv-conf.nix super;
  neovim = import ../overrides/neovim.nix super;
  emacs = import ../overrides/emacs.nix super;
  cli-visualizer = import ../overrides/cli-visualizer.nix super;
  urn = import ../overrides/urn.nix super;
}
