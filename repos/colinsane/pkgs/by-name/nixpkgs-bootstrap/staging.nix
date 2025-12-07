{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9c446ed3419701537f4d4347c4fe4742cc9b6b22";
  sha256 = "sha256-MaYuPpsFIM3GQ7L1WKbrj5/V+ZuCfVpx47R4rTvcLGk=";
  version = "unstable-2025-12-07";
  branch = "staging";
}
