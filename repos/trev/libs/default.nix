{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: {
  buf = import ./buf {inherit pkgs;};
  go = import ./go {inherit pkgs;};
  mkChecks = import ./mkChecks {inherit pkgs;};
}
