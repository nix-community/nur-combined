{
  inputs,
  lib,
  self,
  ...
}:

{
  _module.args.lib' = import "${self}/lib.nix" {
    inherit lib;
    nixpkgs = inputs.nixpkgs.outPath;
  };
}
