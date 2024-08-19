{
  inputs,
  lib,
  self,
  ...
}:

{
  flake.overlays = builtins.listToAttrs (
    map
      (name: {
        name = lib.strings.removeSuffix ".nix" name;
        value = import ../overlays/${name};
      })
      (
        lib.filter (item: lib.strings.hasSuffix ".nix" item) (
          builtins.attrNames (builtins.readDir ../overlays)
        )
      )
  );

  perSystem =
    { pkgs, system, ... }:
    let
      nur = import ./nur.nix { inherit pkgs; };
      overlays = builtins.attrValues self.overlays;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      };
      packages = builtins.removeAttrs nur [
        "overlays"
        "modules"
      ];
    };
}
