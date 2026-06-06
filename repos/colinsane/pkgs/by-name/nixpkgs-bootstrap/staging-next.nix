{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0f73cea4df60b41661d6b7b0b31a7043b81a7dee";
  sha256 = "sha256-mkqXK8st0OlcseyZGon2n+k7SThg+P5LRt3jTza26E0=";
  version = "unstable-2026-06-06";
  branch = "staging-next";
}
