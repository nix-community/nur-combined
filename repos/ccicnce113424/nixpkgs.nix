{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      imports = [ "${inputs.nixpkgs}/nixos/modules/misc/nixpkgs.nix" ];
      nixpkgs = {
        hostPlatform = system;
        overlays = [ ]; # put overlay here
        config.allowUnfree = true;
      };
    };
}
