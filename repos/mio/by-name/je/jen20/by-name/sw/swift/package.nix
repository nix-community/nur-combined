{
  lib,
  llvmPackages,
  llvmPackages_current,
  patchelf,
  runtimeShell,
  stdenv,
  stdenvNoCC,
  stdlib,
  swift-collections,
  swift-corelibs-foundation,
  swift-corelibs-libdispatch,
  swift-corelibs-xctest,
  swift-driver,
  swift-foundation,
  swift-foundation-icu,
  swift-testing,
  swiftc,
  symlinkJoin,
  sysroot,
  swift_release,

  # Tests
  test-cxx-interop,
  test-foundation-macros,
  test-swift-differentiation,
  test-swift-testing,
  test-swift-scripting,
  test-swift-repl,

  enableRepl ? true, # Whether to build and include LLDB for the Swift REPL.
}@args:

let
  getBuildHost = lib.mapAttrs (_: pkg: pkg.__spliced.buildHost or pkg);
  getBuildTarget = lib.mapAttrs (_: pkg: pkg.__spliced.buildTarget or pkg);
  getHostTarget = lib.mapAttrs (_: pkg: pkg.__spliced.hostTarget or pkg);

  buildHostPackages = getBuildHost args;
  hostTargetPackages = getHostTarget args;

  includeTesting = swiftc.supportsMacros && swift-testing != null;

  # The REPL runs entirely inside LLDB (JIT and `dlopen`, no linking), but its ClangImporter
  # needs a sysroot (SDK) to find the C library headers; `swift-driver` turns `SDKROOT` into
  # `-sdk` when constructing the REPL invocation. Scope this to `swift repl` via a dispatcher
  # script — a global `SDKROOT` would add `-sdk` to every compile.
  # From jen20 gist https://gist.github.com/jen20/3b797f020ee81dc564e768f1670ced90
  replSdkWrapper = lib.optionalString (enableRepl && !stdenv.hostPlatform.isDarwin) ''

    # Give only `swift repl` a default SDK (sysroot) for the C library headers.
    if [ -e "$out/bin/swift-driver" ]; then
      rm "$out/bin/swift"
      cat > "$out/bin/swift" <<EOF
    #!${runtimeShell}
    if [ "\$1" = repl ] && [ -z "\''${SDKROOT:-}" ]; then
      export SDKROOT=${sysroot}
    fi
    exec -a "\$0" "$out/bin/swift-driver" "\$@"
    EOF
      chmod +x "$out/bin/swift"
    fi
  '';

  # This makes sure that linking to `libdispatch.so` and `libBlocksRuntime.so` does not pull in previous stages
  # of the bootstrap toolchain.
  swift-corelibs-libdispatch-no-overlay = swift-corelibs-libdispatch.override { useSwift = false; };
  hostTargetPackages_swift-corelibs-libdispatch-no-overlay =
    hostTargetPackages.swift-corelibs-libdispatch.override
      { useSwift = false; };

  # `out` and `dev` are merged because that’s what Swift expects.
  outLinks = symlinkJoin {
    name = "swift" + lib.removePrefix "swiftc" (lib.getName swiftc) + "-${swift_release}-out";
    paths = [
      buildHostPackages.swiftc.out
      hostTargetPackages.swiftc.dev
    ]
    ++ lib.optionals enableRepl [
      # LLDB is used by `swift repl` to provide the REPL.
      buildHostPackages.llvmPackages.lldb.out
    ]
    ++ lib.optionals includeTesting [
      hostTargetPackages.swift-corelibs-xctest.dev
      hostTargetPackages.swift-corelibs-xctest.out
      hostTargetPackages.swift-testing.dev
      hostTargetPackages.swift-testing.out
    ]
    ++ lib.optionals (stdlib != null) [
      hostTargetPackages.stdlib.dev
      hostTargetPackages.stdlib.out
      hostTargetPackages.swiftc.dev
    ]
    ++ lib.optionals (swift-driver != null) [
      buildHostPackages.swift-driver.out
      hostTargetPackages.swift-driver.dev
      hostTargetPackages.swift-driver.lib
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && swift-foundation != null) [
      # Needed for FoundationMacros, which is otherwise not part of the SDK on Darwin.
      hostTargetPackages.swift-foundation.out
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) (
      lib.optionals (swift-corelibs-libdispatch != null) [
        hostTargetPackages.swift-corelibs-libdispatch.out
        hostTargetPackages.swift-corelibs-libdispatch.dev
        hostTargetPackages_swift-corelibs-libdispatch-no-overlay.out
        hostTargetPackages_swift-corelibs-libdispatch-no-overlay.dev
      ]
      ++ lib.optionals (swift-foundation != null) [
        #        hostTargetPackages.swift-collections.dev
        #        hostTargetPackages.swift-collections.out
        hostTargetPackages.swift-corelibs-foundation.out
        hostTargetPackages.swift-corelibs-foundation.dev
        hostTargetPackages.swift-foundation-icu.out
        hostTargetPackages.swift-foundation.dev
        hostTargetPackages.swift-foundation.out
      ]
    );
  };

  #  devLinks = symlinkJoin {
  #    name = "swift" + lib.removePrefix "swiftc" (lib.getName swiftc) + "-${swift_release}-dev";
  #    paths = [
  #      hostTargetPackages.swiftc.dev
  #    ]
  #    ++ lib.optionals includeTesting [
  #      hostTargetPackages.swift-corelibs-xctest.dev
  #      hostTargetPackages.swift-corelibs-xctest.out
  #      hostTargetPackages.swift-testing.dev
  #      hostTargetPackages.swift-testing.out
  #    ]
  #    ++ lib.optionals (stdlib != null) [
  #      hostTargetPackages.stdlib.dev
  #    ]
  #    ++ lib.optionals (swift-driver != null) [
  #      hostTargetPackages.swift-driver.dev
  #    ]
  #    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
  #      buildHostPackages.swift-corelibs-libdispatch.dev
  #      # buildHostPackages.swift-corelibs-foundation.dev
  #    ];
  #  };

  docLinks = symlinkJoin {
    name = "swift" + lib.removePrefix "swiftc" (lib.getName swiftc) + "-${swift_release}-doc";
    paths = [
      hostTargetPackages.swiftc.doc
    ];
  };

  manLinks = symlinkJoin {
    name = "swift" + lib.removePrefix "swiftc" (lib.getName swiftc) + "-${swift_release}-man";
    paths = [
      hostTargetPackages.swiftc.man
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin && swift-corelibs-libdispatch != null) [
      buildHostPackages.swift-corelibs-libdispatch.man
      # buildHostPackages.swift-corelibs-foundation.man
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "swift" + lib.removePrefix "swiftc" (lib.getName swiftc);
  version = swift_release;

  outputs = [
    "out"
    "doc"
    "man"
  ];

  strictDeps = true;

  # Will effectively be `buildInputs` when swift is put in `nativeBuildInputs`.
  depsTargetTargetPropagated =
    lib.optionals (stdlib != null) [
      # Propagate the stdlib to make sure the linker wrapper will pick up the dynamic and static libraries.
      stdlib
    ]
    ++ lib.optionals includeTesting [
      swift-corelibs-xctest.out
      swift-testing.out
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) (
      lib.optionals (swift-corelibs-libdispatch != null) [
        swift-corelibs-libdispatch-no-overlay.out
        swift-corelibs-libdispatch.out
      ]
      ++ lib.optionals (swift-foundation != null) [
        swift-corelibs-foundation.out
        swift-foundation-icu.out
        swift-foundation.out
      ]
    );

  buildCommand = ''
    mkdir -p "$out" "$doc" "man"

    cp -r ${lib.escapeShellArg outLinks}/* "$out"
    cp -r ${lib.escapeShellArg docLinks}/* "$doc"
    cp -r ${lib.escapeShellArg manLinks}/* "$man"

    # Make writable temporarily to allow for the fixups below to be made to the outputs.
    chmod -R u+w "$out/bin" "$out/lib" "$out/nix-support"

    # Swift expects to find Clang next to it.
    ln -s ${lib.escapeShellArg (lib.getExe' (getBuildTarget args).llvmPackages_current.clang "clang")} "$out/bin/clang"

    # `swift-frontend` expects to find everything relative to its location after resolving symlinks.
    # Also copy `swift-driver` assuming it does similar.
    for exe in swift-driver swift-frontend; do
      if [ -e "$out/bin/$exe" ]; then
        orig=$(readlink "$out/bin/$exe")
        rm "$out/bin/$exe"
        cp "$orig" "$out/bin/$exe"
      fi
    done

    # Make sure `swift` and `swiftc` point to `swift-driver` if present.
    if [ -e "$out/bin/swift-driver" ]; then
      for exe in swift swiftc; do
        rm -f "$out/bin/$exe"
        ln -s swift-driver "$out/bin/$exe"
      done
    fi${replSdkWrapper}

    # Propagated inputs in `$dev/nix-support` have to be substituted to use this derivation instead of swiftc.
    for f in "$out/nix-support/"*; do
      orig=$(readlink "$f")
      rm "$f"
      substitute "$orig" "$f" \
        --replace-quiet ${lib.escapeShellArg hostTargetPackages.swiftc.out} "$out"
    done

    # Don’t propagate CMake files for toolchain dependencies. These are an implementation detail of the package set.
    rm -rf "$out/lib/cmake"

    recordPropagatedDependencies

    ${lib.optionalString (stdlib != null) ''
      # Can’t use `replaceVars` because it needs to substitute $out.
      substitute ${./setup-hook.sh} "$out/nix-support/setup-hook" \
        --replace-fail @patchelf@ ${lib.escapeShellArg (lib.getExe buildHostPackages.patchelf)} \
        --replace-fail @objdump@ ${lib.escapeShellArg (lib.getExe' buildHostPackages.llvmPackages_current.llvm "llvm-objdump")} \
        --replace-fail @install_name_tool@ ${lib.escapeShellArg (lib.getExe' buildHostPackages.llvmPackages_current.llvm "llvm-install-name-tool")} \
        --replace-fail @stdlibPath@ ${lib.escapeShellArg stdlib.out} \
        --replace-fail @swiftPath@ "$out" \
        --replace-fail @swiftPlatform@ ${stdenv.hostPlatform.swift.platform}
    ''}
    ${lib.optionalString enableRepl ''
      # LLDB expects to find Swift relative to its location. Both the wrapper and its binary need copied,
      # and the wrapper needs updated to find the binary in the new location.
      lldbBinPath=$(dirname $(readlink "$out/bin/lldb"))
      for lldbExe in lldb .lldb-wrapped; do
        rm "$out/bin/$lldbExe"
        cp "$lldbBinPath/$lldbExe" "$out/bin/$lldbExe"
      done
      substituteInPlace "$out/bin/lldb" \
        --replace-fail "$lldbBinPath" "$out/bin"
    ''}
    chmod -R u-w "$out/bin" "$out/lib" "$out/nix-support"
  '';

  __structuredAttrs = true;

  passthru = {
    inherit swiftc swift-driver;
  };

  passthru.tests = {
    inherit
      test-cxx-interop
      test-foundation-macros
      test-swift-differentiation
      test-swift-scripting
      ;
  }
  // lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
    inherit
      test-swift-repl # Requires `debugserver` and debugging permission, which non-interactive sessions can’t get.
      test-swift-testing # XCTest and Swift Testing does not run on Darwin.
      ;
  };

  # passthru.tests = callPackage ./tests { };

  meta = {
    description = "Swift Programming Language";
    homepage = "https://github.com/swiftlang/swift";
    inherit (swiftc.meta) platforms badPlatforms;
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
