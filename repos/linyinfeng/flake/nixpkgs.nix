{ inputs, ... }:
{
  perSystem =
    { ... }:
    {
      nixpkgs = {
        config.allowInsecurePredicate = _: true;
        overlays = [ inputs.nvfetcher.overlays.default ];
      };
    };
}
