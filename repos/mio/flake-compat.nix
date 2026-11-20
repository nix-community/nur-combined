# Resolve this flake's inputs for Nix implementations without flake support.
#
# nova-nix has no flakes, and its `builtins.fetchTree` is a stub that throws
# "requires experimental feature 'fetch-tree'".  Upstream flake-compat would
# therefore select fetchTree and fail, so this reads flake.lock directly and
# uses the fetchTarball/fetchGit builtins nova-nix implements.
#
# Only the inputs this repository uses are handled: plain `github`, `tarball`
# and `git` entries.  There are no `follows` or path inputs.
{
  src ? ./.,
}:

let
  lock = builtins.fromJSON (builtins.readFile (src + "/flake.lock"));

  fetch =
    locked:
    if locked.type == "github" then
      builtins.fetchTarball {
        url = "https://api.${locked.host or "github.com"}/repos/${locked.owner}/${locked.repo}/tarball/${locked.rev}";
        sha256 = locked.narHash;
      }
    else if locked.type == "tarball" then
      builtins.fetchTarball {
        inherit (locked) url;
        sha256 = locked.narHash;
      }
    else if locked.type == "git" then
      builtins.fetchGit {
        inherit (locked) url rev;
      }
    else
      throw "flake-compat: unsupported flake input type '${locked.type}'";

  root = lock.nodes.${lock.root};
  inputs = builtins.mapAttrs (name: node: fetch lock.nodes.${node}.locked) root.inputs;
  self = (import (src + "/flake.nix")).outputs (inputs // { inherit self; });
in
self
