{
  callPackage,
  source,
}:
callPackage ../sing-box-rc/package.nix {
  pname = "sing-box-alpha";
  inherit source;
  modules = ./gomod2nix.toml;
}
