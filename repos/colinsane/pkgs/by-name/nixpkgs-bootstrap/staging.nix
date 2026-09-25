{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "43a3e4c9afa6b4f76f9b7edfc10a88d6140b6d61";
  sha256 = "sha256-GcggApJorPte49HS0nbNfxomi5tDQuOYxdsiWrjJu2c=";
  version = "unstable-2026-09-24";
  branch = "staging";
}
