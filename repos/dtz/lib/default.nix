rec {
  from-nar = import ./from-nar.nix;
  recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };

  # "borrowed" from tilpner's repo
  listDirectory = import ./listDirectory.nix;
  pathDirectory = listDirectory (x: x);
  importDirectory = listDirectory import;
  #callDirectory = listDirectory (p: pkgs.callPackage p {});
  mkCallDirectory = callPkgs: listDirectory (p: callPkgs p {});
}
