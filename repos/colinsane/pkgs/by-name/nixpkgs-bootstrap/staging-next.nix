{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "bae4d0ecfe2c6c007db288437a41c7ebbb84f397";
  sha256 = "sha256-C7KgVx8/J4brk0b3sn8x/MVnEN1uBnbnxj0zymIlTfc=";
  version = "unstable-2026-06-12";
  branch = "staging-next";
}
