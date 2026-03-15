{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
}:
{
  mkApps = import ./mkApps { inherit pkgs; };
  mkChecks = import ./mkChecks { inherit pkgs; };
  mkImage = import ./mkImage { inherit pkgs; };
}
// import ./pure.nix {
  inherit nixpkgs;
  systems = [ system ];
}
