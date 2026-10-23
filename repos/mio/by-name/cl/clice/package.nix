{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_9,
  python3,
  nodejs,
  patchelf,
  gitUpdater,
}:

# Note regarding upstream Nixpkgs PR #544899 and Issue #371320:
# clice requires its own LLVM/Clang fork (xclang) because it depends on internal
# Clang AST / indexing APIs and ThinLTO bitcode that diverge from upstream LLVM.
# Upstream nixpkgs closed PR #544899 because packaging xclang from source is not
# yet supported upstream. To achieve a hermetic and reproducible build in Nix:
# 1. External dependencies and xclang are fetched in a fixed-output derivation (`deps`)
#    via Bazel's vendor mode and pinned via VENDOR.bazel.
# 2. The main build runs completely offline with `--vendor_dir` pointing to `deps`,
#    preventing any network access during compilation.
stdenv.mkDerivation (finalAttrs: {
  pname = "clice";
  version = "0.1.2026102207";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CARmnqbb8CZEbrdn3b4W+qvCrcHilNthWTYd4/Lysyw=";
  };

  deps = stdenv.mkDerivation {
    name = "clice-deps";
    src = finalAttrs.src;

    nativeBuildInputs = [
      bazel_9
      python3
    ];

    dontCheckForBrokenSymlinks = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
      mkdir -p $TMPDIR/xclang-thinlto
      sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc || true
      # Fetch all external repositories from the network
      bazel vendor -c opt --config=RelWithDebInfo //... --vendor_dir=$out

      # Pin all vendored repositories so that rewriting the registry URL doesn't invalidate them
      for d in $out/*; do
        if [ -d "$d" ]; then
          repo=$(basename "$d")
          if [ "$repo" != "_registries" ] && [[ "$repo" != "@"*.marker ]] && [[ "$repo" != "bazel-external" ]]; then
            # The folder name is the canonical repo name, but the pin() command requires @@ prefix
            echo "pin(\"@@$repo\")" >> $out/VENDOR.bazel
          fi
        fi
      done

      # Remove any store references in vendored files (e.g. marker files containing tool paths)
      grep -rl "/nix/store" "$out" | while read -r f; do
        sed -i -E 's|/nix/store/[a-z0-9]{32}-[^/]+|/dummy|g' "$f"
      done

      runHook postBuild
    '';

    dontFixup = true;

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-e3vcQqhvXmo0+FyDdI2eHOpaQXQya6RCGmtnqbTJQB4=";
  };

  nativeBuildInputs = [
    bazel_9
    python3
    nodejs
    patchelf
  ];

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1

    # Rewrite registry lines to point to the local vendored registries
    sed -i -e "s|https://bazel.clice.io/|file://${finalAttrs.deps}/_registries/bazel.clice.io|g" bazel/clice.bazelrc || true
    sed -i -e "s|https://bcr.bazel.build/|file://${finalAttrs.deps}/_registries/bcr.bazel.build|g" bazel/clice.bazelrc || true

    # ThinLTO cache directory must be in a writable location inside the sandbox
    mkdir -p $TMPDIR/xclang-thinlto
    sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc

    # Copy vendor directory using standard copy (no hardlinks) so it works across filesystems.
    # Bazel attempts to delete .marker files for pinned repositories, which crashes
    # if the vendor directory is a read-only Nix store path.
    cp -R ${finalAttrs.deps} $TMPDIR/vendor
    chmod -R u+w $TMPDIR/vendor

    # Replace /var/tmp/xclang-thinlto in vendored repo files (e.g. thinlto_cache BUILD.bazel)
    find $TMPDIR/vendor -type f -exec sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" {} + 2>/dev/null || true

    # Patch interpreter on prebuilt ELF binaries inside vendored toolchains
    dynamic_linker="$(cat $NIX_CC/nix-support/dynamic-linker)"
    for bin in $TMPDIR/vendor/xclang*x86_64*/bin/* $TMPDIR/vendor/rules_python*x86_64*/bin/python3*; do
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then
        patchelf --set-interpreter "$dynamic_linker" "$bin" 2>/dev/null || true
      fi
    done

    bazel build -c opt --config=RelWithDebInfo //:bin/clice --vendor_dir=$TMPDIR/vendor

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    if [ -f build/RelWithDebInfo/bin/clice ]; then
      install -Dm755 build/RelWithDebInfo/bin/clice "$out/bin/clice"
    else
      find "$TMPDIR" -type f -name "clice" -executable -exec cp -L {} "$out/bin/clice" \;
    fi

    # Ensure it was copied
    if [ ! -f "$out/bin/clice" ]; then
      echo "Failed to find clice binary!"
      exit 1
    fi

    if [ -d build/RelWithDebInfo/lib ]; then
      cp -r build/RelWithDebInfo/lib "$out/lib"
    fi

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) deps;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Next-generation C++ language server built on LLVM/Clang";
    homepage = "https://github.com/clice-io/clice";
    changelog = "https://github.com/clice-io/clice/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "clice";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      fromSource
    ];
  };
})
