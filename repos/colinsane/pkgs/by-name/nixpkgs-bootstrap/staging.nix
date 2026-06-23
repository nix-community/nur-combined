{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "91eba774671d6b5d6591f6733fb4409cf824f3e7";
  sha256 = "sha256-t8JVbAYb3VLCxTcOlVBTFgVVxjJ2os3VPUNZTCtGVFo=";
  version = "unstable-2026-06-23";
  branch = "staging";
}
