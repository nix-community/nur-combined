{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "32d2855779b5a923851feabc28d410a62b72a2bb";
  sha256 = "sha256-FhBMp+S3CQdvdoJOWEp3wkwkGV2SdxBWXxzpsZ+4eGc=";
  version = "unstable-2026-08-24";
  branch = "staging-next";
}
