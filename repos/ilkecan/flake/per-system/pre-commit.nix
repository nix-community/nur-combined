{
  ...
}:

{
  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings = {
        package = pkgs.prek;
        hooks = {
          comrak.enable = true;
          deadnix.enable = true;
          flake-checker.enable = true;
          nil.enable = true;
          nixf-diagnose.enable = true;
          nixfmt.enable = true;
        };
      };
    };
}
