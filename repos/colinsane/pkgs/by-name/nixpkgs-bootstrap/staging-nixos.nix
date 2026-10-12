{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e5fdc859c42d179efca0b3559b6150ed6dc5607c";
  sha256 = "sha256-PmVQXpMgUeeaa3GceZfHcOWZV03jCuKDdhZGo67XIzM=";
  version = "unstable-2026-10-10";
  branch = "staging-nixos";
}
