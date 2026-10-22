{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e244e0e83740a6734b31bd758acc1f1114a6b89f";
  sha256 = "sha256-CIne/hOJ7qGkOH9zc8Jzlu9N6dp5CFs3dBK0+jdDz78=";
  version = "unstable-2026-10-21";
  branch = "staging";
}
