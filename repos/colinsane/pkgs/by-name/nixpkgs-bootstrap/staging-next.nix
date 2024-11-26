{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "d33a22199933acfc5fff998eb262883a9fb74090";
  sha256 = "sha256-EtYRmMcep4cTKGnfiq2toWdulEr7180p6XyYFlvqWeQ=";
  version = "0-unstable-2024-11-25";
  branch = "staging-next";
}
