{
  callPackage,
  source,
}:
callPackage ./package.nix {
  pname = "sing-box-rc";
  inherit source;
  modules = ./gomod2nix.toml;
}
