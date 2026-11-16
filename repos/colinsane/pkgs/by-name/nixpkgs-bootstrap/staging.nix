{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "7c5119ff0747398600e0f1d79376eed3356ea42b";
  sha256 = "sha256-hg14t/vsNzZyPyptRDjuhPE7gEWcI8pgyWqRXEfKq5w=";
  version = "unstable-2026-11-13";
  branch = "staging";
}
