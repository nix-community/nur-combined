{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "5ff390289e135e883d93ba6c5e03ef159fe1db2c";
  sha256 = "sha256-CLsyTton1Z8hFRe3QPFKBIx+fwaLOzsQezFMcuBpkxg=";
  version = "0-unstable-2025-01-20";
  branch = "staging";
}
