{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4376016d164f38710e9300a50cba0522e63fe4e8";
  sha256 = "sha256-npmcV4FVL5Axl8weSmOH6pokwYrKAoPyFOc8PuaUlHk=";
  version = "unstable-2026-08-28";
  branch = "staging";
}
