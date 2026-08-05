# Swift package set scope.
#
# Sources:
# - Base: github:reckenrode/nixpkgs/swift-update-mk2 @ 9bd6cfed336853908d93c95c21f39e0255ac409c
#   (pkgs/top-level/swift-packages.nix), Swift 6.2.4 — WIP rewrite discussed in the Nixpkgs Swift Matrix room.
# - Local adaptations: inject hostPlatform.swift (from the same branch's lib/systems/default.nix)
#   and point by-name overlay at this directory.

{
  lib,
  clangStdenv,
  darwin,
  generateSplicesForMkScope,
  llvmPackages,
  makeScopeWithSplicing',
  stdenvNoCC,
  otherSplices ? generateSplicesForMkScope "swiftPackages",
}:

let
  # From reckenrode/nixpkgs lib/systems/default.nix (swift-update-mk2 @ 9bd6cfed…).
  # Current nixpkgs does not elaborate hostPlatform.swift yet.
  addSwiftPlatform =
    stdenv:
    let
      mkSwift =
        platform:
        let
          arch = platform.uname.processor;
          swiftPlatform =
            if platform.isMacOS then
              "macosx"
            else if platform.isiOS then
              "iphoneos"
            else if platform.isLinux then
              "linux"
            else if platform.isWindows then
              "windows"
            else
              null;
        in
        {
          inherit arch;
          platform = swiftPlatform;
          triple =
            if platform.isDarwin then
              "${arch}-${platform.parsed.vendor.name}-${swiftPlatform}${platform.darwinMinVersion}"
            else
              platform.config;
        };
    in
    stdenv
    // {
      buildPlatform = stdenv.buildPlatform // {
        swift = mkSwift stdenv.buildPlatform;
      };
      hostPlatform = stdenv.hostPlatform // {
        swift = mkSwift stdenv.hostPlatform;
      };
      targetPlatform = stdenv.targetPlatform // {
        swift = mkSwift stdenv.targetPlatform;
      };
    };

  autoCalledPackages = import ./by-name-overlay.nix lib ./by-name;
in

makeScopeWithSplicing' {
  inherit otherSplices;
  extra =
    self:
    let
      bootstrapSwiftPackages = self.overrideScope (
        final: prev: {
          stdlib = null; # Have the bootstrap compiler use its own build of the stdlib.
          swift-bootstrap = prev.swift.override {
            swiftc = prev.swiftc.override { swift-bootstrap = null; };
            swift-corelibs-libdispatch = null;
            swift-driver = null;
            swift-foundation = null;
            swift-testing = null;
            enableRepl = false;
          };
          swift-driver = prev.swift-driver.overrideAttrs (old: {
            pname = "early-${old.pname}";
          });
        }
      );

      llvm_libtool = stdenvNoCC.mkDerivation {
        pname = "libtool";
        version = lib.getVersion llvmPackages.llvm;

        buildCommand = ''
          mkdir -p "$out/bin"
          ln -s ${lib.getExe' llvmPackages.llvm "llvm-libtool-darwin"} "$out/bin/libtool"
        '';
      };
    in
    {
      # inherit (self.swift) mkSwiftPackage; # not yet defined on swift in upstream WIP
      inherit llvm_libtool;

      llvmPackages_current = llvmPackages;
      swift-bootstrap = bootstrapSwiftPackages.swift.override { enableRepl = false; };

      swift-minimal = self.swift.override {
        swift-corelibs-libdispatch = null;
        swift-driver = null;
        swift-foundation = null;
        swift-testing = null;
        enableRepl = false;
      };
    };
  f = lib.extends autoCalledPackages (self: {
    stdenv = addSwiftPlatform clangStdenv;

    # Apple ICU (reckenrode swift-update-mk2 darwin.ICU) — needed for Foundation’s
    # `_FoundationICU` module on Linux (stock nixpkgs ICU lacks Apple headers/APIs).
    # Package: ./ICU (copied from reckenrode mk2 @ 9bd6cfed…).
    swift-corelibs-icu =
      if clangStdenv.hostPlatform.isDarwin then darwin.ICU else darwin.callPackage ./ICU/package.nix { };

    Dispatch = lib.warn "Dispatch has been renamed to swift-corelibs-libdispatch. It is also now included in the default Swift SDK and no longer needs referenced as a separate package." self.swift-corelibs-libdispatch;
    Foundation = lib.warn "Foundation has been renamed to swift-corelibs-foundation. It is also now included in the default Swift SDK and no longer needs referenced as a separate package." self.swift-corelibs-foundation;
    XCTest = lib.warn "XCTest has been renamed to swift-corelibs-xctest. It is also now included in the default Swift SDK and no longer needs referenced as a separate package." self.swift-corelibs-xctest;

    swift_release = "6.2.4";
  });
}
