{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "042d3180cbfa5453c9c7121d3f34a83da8c4fe07";
  sha256 = "sha256-wT+Igfoern47sPuwxqn0t0XH2PCTGNZrA3G7bmIgkFc=";
  version = "0-unstable-2025-01-02";
  branch = "staging";
}
