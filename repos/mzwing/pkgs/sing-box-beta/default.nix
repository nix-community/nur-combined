{
  callPackage,
  source,
}:
callPackage ../sing-box-rc/package.nix {
  pname = "sing-box-beta";
  inherit source;
  modules = ./gomod2nix.toml;
}
