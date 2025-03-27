{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e28407cd08645e26cd42e37b941d52256478bd6e";
  sha256 = "sha256-1bkBfGKoqIMwhl6dfujLOYldKSw9xcFy4Z+rot+SdIs=";
  version = "0-unstable-2025-03-24";
  branch = "staging-next";
}
