{ callPackage }:

{
  update = callPackage ./scripts/update.nix {};
  lint = callPackage ./scripts/lint.nix {};
}
