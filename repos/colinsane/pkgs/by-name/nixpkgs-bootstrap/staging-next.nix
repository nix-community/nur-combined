{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "c2b94332338446cd738f49765c101925393f13eb";
  sha256 = "sha256-y+kcRoJ2zNvqoePWCbqxFGxPQMETxuujJ3+pRmEFTHE=";
  version = "0-unstable-2025-01-21";
  branch = "staging-next";
}
