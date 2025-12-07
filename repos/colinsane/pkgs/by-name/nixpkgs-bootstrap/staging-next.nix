{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8fcded144a91ae92c3f2b3ea29d803cecab337f8";
  sha256 = "sha256-qB0e/mvfgMTENAb3l8rRlzvgDb4psVYwBds4ODLQne8=";
  version = "unstable-2025-12-06";
  branch = "staging-next";
}
