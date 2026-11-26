{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "cfbf6797c6e5df4b126ef1769dfce0f651c9f7db";
  sha256 = "sha256-zAub4blb0pGZplIyTSEW4a6zJb/KtLAsUlklppMgIhw=";
  version = "unstable-2026-11-22";
  branch = "staging-nixos";
}
