{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "66a80f5e4c914603d4849bd87aaff5d507d74f39";
  sha256 = "sha256-3XArw9NnbZrpmN3CD6krkPlwsaXThmZ8WefGyQ0ZcHw=";
  version = "0-unstable-2025-01-25";
  branch = "staging";
}
