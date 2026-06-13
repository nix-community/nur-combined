{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "77807f1f80d8738e17716613c3dba0a8dbb54bd4";
  sha256 = "sha256-6SSmGkOL2N91Dt9LfiaA4SieSECqN2WIwzfXHOyJ5xY=";
  version = "unstable-2026-06-13";
  branch = "staging-next";
}
