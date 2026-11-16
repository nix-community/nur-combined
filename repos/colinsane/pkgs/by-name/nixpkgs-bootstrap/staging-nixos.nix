{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "91ffbd5ab3623ce53bf239d12d7d0748581d1900";
  sha256 = "sha256-zHgtbFeM6e5reecLdiU96q/As202p0EiFk4NslaUYoQ=";
  version = "unstable-2026-11-13";
  branch = "staging-nixos";
}
