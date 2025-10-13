# overlays/default.nix
final: prev: {
  bloodhound-ce = prev.callPackage ../pkgs/bloodhound-ce { };
  bloodhound-ce-desktop = prev.callPackage ../pkgs/bloodhound-ce-desktop { };
}
