{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "233ccf6b48a4fc2a0193054425a5a56072b490b8";
  sha256 = "sha256-sI6QJWs2dI0VORhAGkfjPzeg3ufal5yQ2jJxSt6sZHc=";
  version = "unstable-2025-05-29";
  branch = "staging-next";
}
