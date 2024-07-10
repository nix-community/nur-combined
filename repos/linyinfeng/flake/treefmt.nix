{ ... }:

{
  perSystem =
    { ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          ormolu.enable = true;
          hlint.enable = true;
          shfmt.enable = true;
          black.enable = true;
        };
      };
    };
}
