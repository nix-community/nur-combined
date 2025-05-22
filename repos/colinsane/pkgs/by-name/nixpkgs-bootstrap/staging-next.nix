{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6d3d5e8e000903d8625bba883f1a406f43fea302";
  sha256 = "sha256-BWDvYWD5myUlLqmccNJ/UT2RSIjlIlMh7NowXHNCWgg=";
  version = "unstable-2025-05-19";
  branch = "staging-next";
}
