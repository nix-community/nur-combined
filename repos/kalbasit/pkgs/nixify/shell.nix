let
  # Look here for information about how to generate `nixpkgs-version.json`.
  #  → https://wiki.nixos.org/wiki/FAQ/Pinning_Nixpkgs
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = import
    (builtins.fetchGit {
      inherit (pinnedVersion) url rev;

      ref = "{{ref}}";
    })
    { };
in

# This allows overriding pkgs by passing `--arg pkgs ...`
{ pkgs ? pinnedPkgs }:

with pkgs;

mkShell {
  buildInputs = [
    # put packages here.
  ];
}
