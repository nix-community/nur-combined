{
  systems ? [ builtins.currentSystem ],
  branches ? [ "nixpkgs-unstable" ],
}:

let
  # flatten is taken from nixpkgs lib
  flatten = x: if builtins.isList x then builtins.concatMap (y: flatten y) x else [ x ];
  getPkgs =
    cursys: branch: import (builtins.getFlake "github:NixOS/nixpkgs/${branch}") { system = cursys; };
  getCacheOutputs = cursys: branch: (import ./ci.nix { pkgs = getPkgs cursys branch; }).cacheOutputs;
in
flatten (map (branch: map (system: getCacheOutputs system branch) systems) branches)
