{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "699d570bcdb11410e4379c0bb8cbdb88269eec08";
  sha256 = "sha256-vGGtGTFc7ShzWtdsI3zDVomWcHkozZ0kU0eGbeM8Irk=";
  version = "unstable-2026-10-18";
  branch = "staging-nixos";
}
