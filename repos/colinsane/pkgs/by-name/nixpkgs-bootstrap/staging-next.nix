{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b6ba3caa1bf83f467161dbd0f161055bfc0a40cb";
  sha256 = "sha256-dD17uuhUkCzVHqf7ezWbWr7J2zZymeTrWkMw4zD5xQY=";
  version = "unstable-2025-05-15";
  branch = "staging-next";
}
