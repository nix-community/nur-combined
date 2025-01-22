{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "30be0b9eba696882c6dfc60f263c84a381318ac9";
  sha256 = "sha256-AsVEteW8F5jFUhW4tmK1IlIamKv5dHwQ05ePBG4RAf4=";
  version = "0-unstable-2025-01-22";
  branch = "staging";
}
