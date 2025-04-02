{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "635d5c222e26e8caa10f2c174a54f45478a56ded";
  sha256 = "sha256-FANxTDhjEjX2cd66OcTlOa6+lKhZyVkKgRcCLW9PoxI=";
  version = "0-unstable-2025-03-31";
  branch = "staging-next";
}
