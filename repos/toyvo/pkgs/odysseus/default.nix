# Odysseus AI assistant (https://github.com/odysseus-dev/odysseus).
#
# The packaging and service modules live in this repo after
# odysseus-dev/odysseus#2568 was closed unmerged. The source is the flake's
# non-flake `odysseus` input (tracking upstream `dev`); when evaluated
# without flake inputs in scope (e.g. as a NUR package) it falls back to the
# pinned rev/hash in versions.json — keep that file in sync with flake.lock
# when updating the input.
#
# NOTE: `src` is computed here rather than taken as a callPackage argument on
# purpose — nixpkgs has a `src` alias (simple-revision-control) that throws
# when auto-filled from the callPackage scope.
{
  callPackage,
  fetchFromGitHub,
  inputs ? { },
  extraPythonPackages ? _ps: [ ],
  extras ? [ ],
  lib,
  ...
}:
let
  pinned = builtins.fromJSON (builtins.readFile ./versions.json);
  src = inputs.odysseus or (fetchFromGitHub {
    owner = "odysseus-dev";
    repo = "odysseus";
    inherit (pinned) rev hash;
  });
in
callPackage ./derivation.nix {
  inherit lib src extraPythonPackages extras;
}
