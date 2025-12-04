{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0ee020a919d81ee0acfc1c61fd6a689faf357010";
  sha256 = "sha256-HNCwId5xocXbv/xWhLtENArUYPkzysMSGAlmrwX/DL0=";
  version = "unstable-2025-12-04";
  branch = "staging-next";
}
