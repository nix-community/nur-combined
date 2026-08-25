{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8beb0d13f0e22439c1608b4008f35472fc58b954";
  sha256 = "sha256-9DbYQiyE7EpE+mB/4hmEK+ghIGl3NVaUfgJjbgO2geE=";
  version = "unstable-2026-08-24";
  branch = "staging";
}
