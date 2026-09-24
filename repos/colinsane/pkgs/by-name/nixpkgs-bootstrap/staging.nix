{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "63368e65a2e606eaab67fe85741899337d3075da";
  sha256 = "sha256-5kx1MaiiTdlGAdZs531Jiiy3D4DW7MNhPFBmKbaeEL4=";
  version = "unstable-2026-09-22";
  branch = "staging";
}
