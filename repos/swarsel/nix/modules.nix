{ self, inputs, ... }:
{
  flake = _:
    let
      lib = inputs.nixpkgs.lib;
    in
      {
        nixosModules.default = import "${self}/modules/nixos" { inherit self lib; };
        homeModules.default = import "${self}/modules/home" { inherit self lib; };
      };
}
