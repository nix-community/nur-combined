{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem = {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        # formatter
        treefmt.enable = true;
        # security
        trufflehog.enable = true;
        # nix
        flake-checker.enable = true;
      };
    };
  };
}
