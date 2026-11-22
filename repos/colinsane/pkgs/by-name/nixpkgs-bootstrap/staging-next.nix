{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "e5a330c77fc80c35fdfbb30ab85e6595e69833d4";
  sha256 = "sha256-GVztVc5P3otGzkM6/cwE7NBqVeAqYzIZPBqMnhrRzlU=";
  version = "unstable-2026-11-21";
  branch = "staging-next";
}
