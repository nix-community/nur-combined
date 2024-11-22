{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "23e89b7da85c3640bbc2173fe04f4bd114342367";
  sha256 = "sha256-y/MEyuJ5oBWrWAic/14LaIr/u5E0wRVzyYsouYY3W6w=";
  version = "0-unstable-2024-11-19";
  branch = "master";
}
