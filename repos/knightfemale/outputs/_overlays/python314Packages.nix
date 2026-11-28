final: prev:
let
  python314PackagesRaw = prev.callPackage ../_legacyPackages/python314Packages { };

  inherit (prev.stdenv.hostPlatform)
    isLinux
    ;
in
{
  inherit
    python314PackagesRaw
    ;

  lada =
    if isLinux then final.python314Packages.toPythonApplication final.python314Packages.lada else null;

  python314Packages = prev.python314Packages.override {
    overrides = _pyFinal: _pyPrev: python314PackagesRaw;
  };
}
