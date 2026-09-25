{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "add458b2a4b92d5e483a9082babb30d74e9b295d";
  sha256 = "sha256-aMjJWhcmbjsJPLNJM79QmfXhFmE8kyRv0IMOqDo+PqA=";
  version = "unstable-2026-09-25";
  branch = "staging-next";
}
