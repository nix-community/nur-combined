{
  self,
  inputs,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.lib' = import "${self}/lib.nix" { inherit pkgs; };
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
    };
}
