rec {
  default = _final: prev: (import ../pkgs { pkgs = prev; }).legacyPackages;
  withNamespace = _final: prev: { fym998-nur = default _final prev; };
}
