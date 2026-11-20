{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "a1ddfaf8dd4d033b173e6858a0cd4c3b8f84ea50";
  sha256 = "sha256-ZLgUvN3SDiRI2OYgKrI3LNRLn+jinOUdZ1k6axLtkNI=";
  version = "unstable-2026-11-19";
  branch = "staging-next";
}
