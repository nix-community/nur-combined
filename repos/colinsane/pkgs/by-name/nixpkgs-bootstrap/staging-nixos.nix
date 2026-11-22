{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "8eecacd82aff7a59dfe3598fbaa89f268102ec49";
  sha256 = "sha256-6SBdjdhnx+bNDFL1nDEoh83M6CwLQnvDtFQAfvUGZDg=";
  version = "unstable-2026-11-21";
  branch = "staging-nixos";
}
