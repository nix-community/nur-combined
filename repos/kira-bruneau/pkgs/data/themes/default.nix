{ pkgs }:

with pkgs;

{
  sddm = recurseIntoAttrs {
    clairvoyance = callPackage ./sddm/clairvoyance { };
  };
}
