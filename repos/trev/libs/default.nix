{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  buf = import ./buf { inherit pkgs; };
  go = import ./go { inherit pkgs; };
  deno = import ./deno { inherit pkgs; };
  rust = import ./rust { inherit system nixpkgs pkgs; };
  mkApps = import ./mkApps { inherit pkgs; };
  mkChecks = import ./mkChecks { inherit pkgs; };
}
// import ./pure.nix {
  systems = [ system ];
}
