{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c13a6121057b0837d555584e6d91b24c2ff4107d";
  sha256 = "sha256-1vs5hJD8KudeXi0qowqEEwgSyXA+0EyKaYJNUhd/eWU=";
  version = "unstable-2025-12-04";
  branch = "staging";
}
