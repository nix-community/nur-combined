{ pkgs, ... }:
with pkgs.lib;
let
  # Resolve every directory under ./pkgs/ into a derivation through
  # callPackage, with both nixpkgs and the NUR set itself in scope. NUR
  # packages can therefore depend on each other unqualified, the same way
  # nixpkgs packages can refer to siblings without a `pkgs.` prefix.
  #
  # We also expose `nurTests` (the NUR-local equivalent of `nixosTests`)
  # so packages can mirror upstream's `passthru.tests = { inherit
  # (nixosTests) <pkg>; };` idiom. The reference is lazy, so the
  # mypkgs <-> nurTests cycle (a test consumes its package, the package
  # references the test in passthru) does not blow up evaluation.
  callPackage = callPackageWith (
    pkgs
    // mypkgs
    // {
      nurTests = import ../tests { inherit pkgs; };
    }
  );
  mypkgs = pipe (builtins.readDir ./.) [
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (k: v: callPackage ./${k} { }))
  ];
in
filterAttrs (
  k: v: !(v.meta ? platforms) || (builtins.elem pkgs.stdenv.hostPlatform.system v.meta.platforms)
) mypkgs
