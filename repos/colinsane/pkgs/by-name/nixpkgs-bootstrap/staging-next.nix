{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "da925a398bcd67339e5ad79845b5093e622c9fd6";
  sha256 = "sha256-WNCo3ciAaydthJmzwZF77ag/EcrWrY43Uf9w9DVUGmE=";
  version = "unstable-2026-11-22";
  branch = "staging-next";
}
