{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c608b274c77f47f0d790f5942f0ffa259a02a798";
  sha256 = "sha256-zHgtbFeM6e5reecLdiU96q/As202p0EiFk4NslaUYoQ=";
  version = "unstable-2026-11-13";
  branch = "staging-next";
}
