{ emacsPackages }:
final: prev: {
  eglot-ltex = prev.eglot-ltex.overrideAttrs (_: {
    buildInputs = with emacsPackages; [ f ];
  });

  org-bars = prev.org-bars.overrideAttrs (_: {
    buildInputs = with emacsPackages; [
      dash
      s
    ];
  });
}
