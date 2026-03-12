{
  rust,
  callPackage,
  lib,
}:

rust
// lib.filterAttrs (_: v: v != null) {
  compile = if rust ? compile then null else callPackage ./compile.nix { };
}
