{ inputs, lib, ... }:
{
  perSystem =
    { ... }:
    {
      nixpkgs = {
        config.allowInsecurePredicate = _: true;
        overlays = [ inputs.nvfetcher.overlays.default ] ++ (lib.attrValues (import ../overlays));
      };
    };
}
