{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "8c2d58df123aafefb5301e31b12d850cf0599abf";
  sha256 = "sha256-zxHhbvoM8+eYQgggJ7fVok/bcs/tWgydtaV+RKkJ5cw=";
  version = "0-unstable-2024-11-26";
  branch = "staging-next";
}
