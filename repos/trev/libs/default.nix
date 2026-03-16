{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
}:
{
  mkApps = import ./mkApps { inherit system pkgs; };
  mkChecks = import ./mkChecks { inherit system pkgs; };
}
// import ./pure.nix {
  inherit nixpkgs;
  systems = [ system ];
}
