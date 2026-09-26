{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4230018f6a9572df75a2ae0f991631304e41643f";
  sha256 = "sha256-n6TjYxYt2lsjjscjxW2ktG6eF6u/6Zjh5JpCSDkCXnQ=";
  version = "unstable-2026-09-26";
  branch = "staging";
}
