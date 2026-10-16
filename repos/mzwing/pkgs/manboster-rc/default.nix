{
  callPackage,
  source,
}:
callPackage ../manboster/package.nix {
  pname = "manboster-rc";
  inherit source;
  modules = ./gomod2nix.toml;
}
