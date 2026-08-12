{
  ...
}:

{
  perSystem =
    { config, ... }:
    {
      devShells = {
        default = config.devShells.preCommit;
        preCommit = config.pre-commit.devShell;
      };
    };
}
