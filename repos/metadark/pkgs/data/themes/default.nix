{ pkgs }:

with pkgs; {
  sddm = {
    clairvoyance = callPackage ./sddm/clairvoyance { };
  };
}
