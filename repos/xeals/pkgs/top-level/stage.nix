# Composes a single bootstrapping of the package collection. The result is a set
# of all the packages for some particular platform.

{ lib
, pkgs
}:
let

  # An overlay to auto-call packages in .../by-name.
  autoCalledPackages =
    import ./by-name-overlay.nix { inherit pkgs lib; } ../by-name;

  allPackages = _self: _super:
    import ./all-packages.nix { inherit pkgs lib; };

  toFix = (lib.flip lib.composeManyExtensions) (_self: { }) [
    autoCalledPackages
    allPackages
  ];

in

# Return the complete set of packages.
lib.fix toFix
