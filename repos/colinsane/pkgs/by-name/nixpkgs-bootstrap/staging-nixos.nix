{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0555c1a65d237019c07469bfb5f255c48822f1de";
  sha256 = "sha256-zLhKs6eBOL8BoQ+gXi3W0r46K6DvUM1pKWDigPdxs0M=";
  version = "unstable-2026-09-24";
  branch = "staging-nixos";
}
