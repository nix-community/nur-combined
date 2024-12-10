{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "dd51f52372a20a93c219e8216fe528a648ffcbf4";
  sha256 = "sha256-NQEO/nZWWGTGlkBWtCs/1iF1yl2lmQ1oY/8YZrumn3I=";
  version = "0-unstable-2024-12-08";
  branch = "master";
}
