{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "e77193f2871b42c009cdaeecb3a85d94a91894c6";
  sha256 = "sha256-yMLcO82uZ2T9PGDQDLqW+Ih3BUU3lDcyQXx2KTZlqfg=";
  version = "unstable-2026-11-19";
  branch = "staging";
}
