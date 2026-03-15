{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
}:
{
  mkApps = import ./mkApps { inherit system pkgs; };
  mkChecks = import ./mkChecks { inherit system pkgs; };
  mkImages = import ./mkImages { inherit nixpkgs system pkgs; };
  mkPackages = import ./mkPackages { inherit nixpkgs system pkgs; };
}
// import ./pure.nix {
  systems = [ system ];
}
