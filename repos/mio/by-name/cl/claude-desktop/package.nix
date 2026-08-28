{
  callPackage,
  fetchFromGitHub,
}:

let
  upstream = import ./upstream.nix { inherit fetchFromGitHub; };
in
callPackage (upstream + "/nix/claude-desktop.nix") { }
