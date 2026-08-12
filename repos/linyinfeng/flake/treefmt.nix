{ ... }:

{
  perSystem =
    { lib, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          ormolu.enable = true;
          hlint.enable = true;
          shfmt.enable = true;
          black.enable = true;
          keep-sorted.enable = true;
        };
        settings.formatter = {
          keep-sorted = {
            includes = lib.mkForce [
              "*.nix"
              "*.hs"
            ];
          };
        };
      };
    };
}
