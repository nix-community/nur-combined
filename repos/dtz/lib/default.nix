{
  from-nar = import ./from-nar.nix;
  recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };
}
