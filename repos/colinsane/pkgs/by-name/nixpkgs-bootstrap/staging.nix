{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b827578a7c68120fdcd0acf40066cb5fdef58d28";
  sha256 = "sha256-47YPEbZH21ZLrZ6A2y75Z49EtRx34eR002DUlbRjrow=";
  version = "unstable-2025-05-13";
  branch = "staging";
}
