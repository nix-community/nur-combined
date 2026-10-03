{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "cb5d9c37e9f6c90e8fc5972ad7b018830a907c80";
  sha256 = "sha256-A7BXHYKiFtdVLrpvrBRWGdXcvw6LMJ42gpse7X2jIm4=";
  version = "unstable-2026-10-03";
  branch = "staging-nixos";
}
