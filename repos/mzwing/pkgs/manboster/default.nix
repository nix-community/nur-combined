{
  callPackage,
  source,
}:
callPackage ./package.nix {
  pname = "manboster";
  inherit source;
  modules = ./gomod2nix.toml;
}
