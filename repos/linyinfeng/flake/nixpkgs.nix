{ inputs, ... }:
{
  perSystem =
    { ... }:
    {
      nixpkgs.overlays = [ inputs.nvfetcher.overlays.default ];
    };
}
