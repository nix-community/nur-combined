{
  system,
  nixpkgs,
  pkgs,
}:
{
  compile = pkgs.lib.makeOverridable (
    {
      package,
      target ? pkgs.stdenv.buildPlatform.config,
      ...
    }:
    let
      crossSystem = pkgs.lib.systems.elaborate {
        config = target;
      };
      crossPkgs = import nixpkgs {
        inherit system crossSystem;
      };
    in
    if system == crossSystem.system then
      pkgs.rustPlatform.buildRustPackage package
    else
      crossPkgs.rustPlatform.buildRustPackage package
  );
}
