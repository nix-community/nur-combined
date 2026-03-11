{
  rust,
  callPackage,
}:

rust
// {
  compile = callPackage ./compile.nix { };
}
