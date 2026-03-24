# Resolve flake inputs from flake.lock for non-flake usage (e.g. NUR evaluator, ci.nix).
# Only resolves non-flake inputs (flake = false); real flake inputs are handled separately.
# In flake context, sources are passed from flake inputs directly.
#
# Uses pkgs.fetchFromGitHub instead of builtins.fetchTarball so that source
# fetching happens at build time (fixed-output derivation), not evaluation time.
# This is required for NUR's restricted-eval mode which blocks network access
# during evaluation.
{ pkgs }:
let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  root = lock.nodes.${lock.root};

  fetchInput = name:
    let
      inputRef = root.inputs.${name};
      nodeName = if builtins.isList inputRef then builtins.head inputRef else inputRef;
      node = lock.nodes.${nodeName};
      locked = node.locked;
    in
    pkgs.fetchFromGitHub {
      owner = locked.owner;
      repo = locked.repo;
      rev = locked.rev;
      hash = locked.narHash;
    };

  isNonFlakeInput = name:
    let
      inputRef = root.inputs.${name};
      nodeName = if builtins.isList inputRef then builtins.head inputRef else inputRef;
      node = lock.nodes.${nodeName};
    in
    node ? flake && node.flake == false;

  sourceNames = builtins.filter isNonFlakeInput
    (builtins.attrNames (builtins.removeAttrs root.inputs [ "nixpkgs" ]));
in
builtins.listToAttrs (map (name: { inherit name; value = fetchInput name; }) sourceNames)
