{
  callPackage,
  source,
}:
callPackage ../manboster/package.nix {
  pname = "manboster-beta";
  inherit source;
  modules = ./gomod2nix.toml;
}
