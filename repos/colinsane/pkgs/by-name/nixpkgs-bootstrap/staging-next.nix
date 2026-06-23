{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9043fb35f8773f73cd256fd7a2268e16302f6732";
  sha256 = "sha256-AoenY58B54KHQQciM8CcJUAUaKCbizV04Z5DxQZ5+XU=";
  version = "unstable-2026-06-22";
  branch = "staging-next";
}
