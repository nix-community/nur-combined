{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "957381b45f6a3b8d1dfe68d621082fae5f8e0c57";
  sha256 = "sha256-CrqlTL+qS9mPUuzSf6KfIslxhSTKlNR94XtrDvIB6lQ=";
  version = "unstable-2026-10-09";
  branch = "staging";
}
