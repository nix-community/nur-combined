{
  haskell,
  haskellPackages,
  fetchFromGitea,
}:
haskell.lib.justStaticExecutables (
  haskellPackages.callCabal2nix "bibman" (fetchFromGitea {
    domain = "codeberg.org";
    owner = "KMIJPH";
    repo = "bibman";
    rev = "0.4";
    hash = "sha256-L7T0oyAzlYavbOHbTdgvSzRf+9E9VuKD1lrc7PJl4/M=";
  }) {}
)
