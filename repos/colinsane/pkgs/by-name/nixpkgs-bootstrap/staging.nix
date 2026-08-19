{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2289494bc4a19516028b32d1cc1c0cfb231bc559";
  sha256 = "sha256-UY3Zdud8EkmTwFxbkZ/ukMu9t5tAVXn8sKP2pWO5KOs=";
  version = "unstable-2026-08-18";
  branch = "staging";
}
