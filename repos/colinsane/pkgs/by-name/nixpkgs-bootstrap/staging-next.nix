{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d1d2801c80409b976e1bc1de1fbe807b9263e2c6";
  sha256 = "sha256-inlGcepk7PRscEbDEGE4up8+LcaFDthXPHi+YMkpVN0=";
  version = "unstable-2026-10-09";
  branch = "staging-next";
}
