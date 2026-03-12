{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  mkApps = import ./mkApps { inherit pkgs; };
  mkChecks = import ./mkChecks { inherit pkgs; };
  mkPackages = import ./mkPackages { inherit pkgs; };
}
// import ./pure.nix {
  systems = [ system ];
}
