{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "6d78a7d119cafea7d551d4f5fb5ac6fa8145c266";
  sha256 = "sha256-qERz54AgvhH4QqLXTfM+JdQHmfHd7Blne2vWfLHwBEM=";
  version = "0-unstable-2024-12-10";
  branch = "master";
}
