{
  callPackage,
  fetchFromGitHub,
  claude-desktop,
}:

let
  upstream = import ../claude-desktop/upstream.nix { inherit fetchFromGitHub; };
in
callPackage (upstream + "/nix/fhs.nix") {
  inherit claude-desktop;
}
