# Swift 6.2.4 toolchain (WIP nixpkgs packaging).
#
# Sources (see README.md for full provenance):
# - Base tree: github:reckenrode/nixpkgs branch swift-update-mk2
#   commit 9bd6cfed336853908d93c95c21f39e0255ac409c
#   (pkgs/development/compilers/swiftPackages + pkgs/top-level/swift-packages.nix)
# - Linux REPL / C++ interop / sysroot fixes: jen20 gist
#   https://gist.github.com/jen20/3b797f020ee81dc564e768f1670ced90
#   (Nixpkgs Swift Matrix discussion; aarch64-linux verified by jen20)
# - Stdlib LTO + llc bitcode→native (Cxx archives, swiftrt.o, -relocation-model=pic):
#   Randy Eckenrode on the same branch / Matrix; PIC+swiftrt needed for Linux PIE links
# - Linux ICU: vendored mk2 darwin/ICU → ./ICU (Apple ICU + libicucore)
# - Related REPL test fixes: github:booxter/nixpkgs/fix-swift-repl
# - Local: 0011-link-clangBasic-from-swiftBasic.patch (DarwinSDKInfo with external Clang)
#
# Attribute `swift6-jen20` is the assembled `swift` toolchain.
# Full set: `swift6-jen20.passthru.swiftPackages`.

{
  lib,
  pkgs,
}:

let
  pkgs' = pkgs.extend (
    final: prev: {
      swiftPackages = lib.recurseIntoAttrs (final.callPackage ./swift-packages.nix { });
      inherit (final.swiftPackages)
        fetchSwiftPMDeps
        swift
        swiftpm
        sourcekit-lsp
        swift-format
        swiftpm2nix
        ;
    }
  );
in
pkgs'.swift.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Swift 6.2.4 (reckenrode swift-update-mk2 + jen20 Linux fixes)";
    # Upstream WIP; not yet in nixpkgs. Prefer tracking reckenrode’s branch / Matrix room.
    broken = false;
  };
  passthru = (old.passthru or { }) // {
    inherit (pkgs') swiftPackages;
    # Convenience aliases matching nixpkgs inherit list.
    inherit (pkgs'.swiftPackages)
      swiftpm
      sourcekit-lsp
      swift-format
      swiftpm2nix
      fetchSwiftPMDeps
      ;
  };
})
