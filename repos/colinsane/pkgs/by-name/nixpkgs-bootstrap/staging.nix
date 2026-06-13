{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "cd372cd5e5cc3d7c734296487543f0348a25e513";
  sha256 = "sha256-XM6p88Krz0m/l47CgJh3IDBQ/sO7s6SpGQy8u61pCRs=";
  version = "unstable-2026-06-13";
  branch = "staging";
}
