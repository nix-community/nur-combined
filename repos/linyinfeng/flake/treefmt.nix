{ ... }:

{
  perSystem =
    { ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt-rfc-style.enable = true;
          ormolu.enable = true;
          hlint.enable = true;
          shfmt.enable = true;
          black.enable = true;
        };
      };
    };
}
