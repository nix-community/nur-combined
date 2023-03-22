{ self, inputs, ... }:
{
  imports = [
    inputs.pre-commit-hooks.flakeModule
  ];

  perSystem = { system, ... }: {
    pre-commit = {
      # Add itself to `nix flake check`
      check.enable = true;

      settings = {
        hooks = {
          nixpkgs-fmt = {
            enable = true;
          };

          shellcheck = {
            enable = true;
          };
        };
      };
    };
  };
}
