{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "49e3c7d54c21ad2d022ac6e2a8c353e410a7b3ee";
  sha256 = "sha256-AURN860YcL49nUKCYvkEs3d47klZ0//SimCaJ7eNOec=";
  version = "0-unstable-2025-04-22";
  branch = "staging";
}
