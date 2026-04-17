{ ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
        inputsFrom = [ config.flake-root.devShell ];
        buildInputs = with pkgs; [
          just
          rage
          b3sum
          nushell
          radicle-node
        ];
      };

    };
}
