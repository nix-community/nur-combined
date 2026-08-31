{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "11c16ede2074a532f69f0b97dcd3a03c909bad97";
  sha256 = "sha256-2vWne7MCZwwRVnVC9kClH7T7QiLhOhXMt4MUy6x61Pg=";
  version = "unstable-2026-08-30";
  branch = "staging-next";
}
