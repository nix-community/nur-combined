{pkgs, ...}: final: prev: {
  eglot-ltex = prev.eglot-ltex.overrideAttrs (_: {
    buildInputs = with pkgs.emacsPackages; [f];
  });

  indent-bars = prev.indent-bars.overrideAttrs (_: {
    buildInputs = with pkgs.emacsPackages; [compat];
  });

  org-bars = prev.org-bars.overrideAttrs (_: {
    buildInputs = with pkgs.emacsPackages; [dash s];
  });

  smartparens = prev.smartparens.overrideAttrs (_: {
    buildInputs = with pkgs.emacsPackages; [dash];
  });

  clangd-inactive-regions = pkgs.lib.warn "clangd-inactive-regions has been renamed to eglot-inactive-regions" prev.eglot-inactive-regions;
}
