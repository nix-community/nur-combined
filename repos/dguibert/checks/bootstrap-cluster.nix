{
  config,
  withSystem,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: let
    # fails
    pkgs' = import inputs'.nixpkgs {
      inherit system;
      overlays = [
        inputs'.self.overlays.default
      ];
      config.replaceStdenv = import ../stdenv.nix;
    };
  in {
    checks.zlib = pkgs.zlib;
    #infinite_recursion = if (builtins.tryEval (builtins.deepSeq pkgs'.zlib pkgs'.zlib)).success then throw "this should have failed with 'infinite recursion'" else null;
  };
}
