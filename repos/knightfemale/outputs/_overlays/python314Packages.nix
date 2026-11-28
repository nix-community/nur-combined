final: prev:
let
  python314PackagesRaw = prev.callPackage ../_legacyPackages/python314Packages { };
in
{
  inherit
    python314PackagesRaw
    ;

  python314Packages = prev.python314Packages.override {
    overrides = _pyFinal: _pyPrev: python314PackagesRaw;
  };
}
