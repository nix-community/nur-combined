{ pkgs ? import ../../../nix { } }:
let
  node = pkgs.nodejs-10_x;
in
# We need make sure that `nodejs` does not default to `nodejs-10_x` because
  # then our test cannot ensure that we can override the default. If the assert
  # below throws, change `node` above to a different version.
assert pkgs.nodejs == node -> throw "`nodejs` is refering to `nodejs-10_x` rendering this test ineffective.";
pkgs.npmlock2nix.v1.shell {
  src = ./.;
  nodejs = node;
}
