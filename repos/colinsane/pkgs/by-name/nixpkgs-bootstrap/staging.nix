{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "942be98f987f55c60b219ee02626f450b683f4ab";
  sha256 = "sha256-JgQv8cOx9sPcjhPyVWN7jvoKzp7r1kSwimhSWV7SQio=";
  version = "0-unstable-2024-12-08";
  branch = "staging";
}
