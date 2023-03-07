{ self, pre-commit-hooks, ... }:
system:
{
  pre-commit = pre-commit-hooks.lib.${system}.run {
    src = self;

    hooks = {
      nixpkgs-fmt = {
        enable = true;
      };

      shellcheck = {
        enable = true;
      };
    };
  };
}
