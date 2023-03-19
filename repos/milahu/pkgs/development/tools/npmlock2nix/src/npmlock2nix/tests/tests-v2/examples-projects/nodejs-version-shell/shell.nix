{ pkgs ? import ../../../../nix { } }:
let
  node = pkgs.nodejs-17_x;
in
# We need make sure that `nodejs` does not default to `nodejs-14_x` because
  # then our test cannot ensure that we can override the default. If the assert
  # below throws, change `node` above to a different version.
assert pkgs.nodejs == node -> throw "`pkgs.nodejs` is refering to `nodejs-17_x` rendering this test ineffective.";
pkgs.npmlock2nix.v2.shell {
  src = ./.;
  nodejs = node;
}
