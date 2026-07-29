{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9e38ebbb4c6a739a1cc5725a97de9e7b0de58c67";
  sha256 = "sha256-k4lUJJahqdiHFfpLrOpUXWkyskLY+lvnaWKr8PTJL1A=";
  version = "unstable-2026-07-28";
  branch = "staging";
}
