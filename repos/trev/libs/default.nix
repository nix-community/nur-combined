{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  buf = import ./buf { inherit pkgs; };
  deno = import ./deno { inherit pkgs; };
  gleam = import ./gleam { inherit pkgs; };
  go = import ./go { inherit pkgs; };
  mkApps = import ./mkApps { inherit pkgs; };
  mkChecks = import ./mkChecks { inherit pkgs; };
  rust = import ./rust { inherit pkgs; };
}
// import ./pure.nix {
  systems = [ system ];
}
