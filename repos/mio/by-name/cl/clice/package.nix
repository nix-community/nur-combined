{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  buildFHSEnv,
  writeShellScriptBin,
  python3,
  nodejs,
  removeReferencesTo,
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
let
  bazel_9_bin = fetchurl {
    url = "https://github.com/bazelbuild/bazel/releases/download/9.2.0/bazel-9.2.0-linux-x86_64";
    hash = "sha256-g5Ex099AioWOG32vTs9nGo0oTLmH5e0q/CmbuI0Cg+A=";
    executable = true;
  };

  # Wrap bazel inside an FHS environment so it can execute without patchelf corruption
  bazel_env = buildFHSEnv {
    name = "bazel-env";
    targetPkgs =
      pkgs: with pkgs; [
        gcc
        zlib
        python3
      ];
    extraBwrapArgs = [
      "--tmpfs"
      "/var"
      "--bind"
      "/tmp"
      "/var/tmp"
    ];
    runScript = "bash";
  };

  bazel_9 = writeShellScriptBin "bazel" ''
    mkdir -p /tmp/xclang-thinlto
    exec ${bazel_env}/bin/bazel-env -c '"$0" "$@"' ${bazel_9_bin} "$@"
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "clice";
  version = "0.1.2026101507";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ztg9zE5aIvcu2laWIgmvfm02FBMS+wjK01RzQeW2khM=";
  };

  deps = stdenv.mkDerivation {
    name = "clice-deps";
    src = finalAttrs.src;

    nativeBuildInputs = [
      bazel_9
      python3
      removeReferencesTo
    ];

    dontCheckForBrokenSymlinks = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
      # First pass: Fetch all external repositories from the network
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

      runHook postBuild
    '';

    dontFixup = true;

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-RvOMal9eVdCWgLu9fAR00YE0uUjX7PGcvwHfxiL0XMk=";
  };

  nativeBuildInputs = [
    bazel_9
    python3
    nodejs
  ];

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1

    # Rewrite registry lines to point to the local vendored registries
    sed -i -e "s|https://bazel.clice.io/|file://${finalAttrs.deps}/_registries/bazel.clice.io|g" bazel/clice.bazelrc || true
    sed -i -e "s|https://bcr.bazel.build/|file://${finalAttrs.deps}/_registries/bcr.bazel.build|g" bazel/clice.bazelrc || true

    # Copy vendor directory using standard copy (no hardlinks) so it works across filesystems.
    # Bazel attempts to delete .marker files for pinned repositories, which crashes
    # if the vendor directory is a read-only Nix store path.
    cp -R ${finalAttrs.deps} $TMPDIR/vendor
    chmod -R u+w $TMPDIR/vendor

    bazel build -c opt --config=RelWithDebInfo //... --vendor_dir=$TMPDIR/vendor

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    find "$TMPDIR" -type f -name "clice" -executable -exec cp -L {} "$out/bin/clice" \;

    # Ensure it was copied
    if [ ! -f "$out/bin/clice" ]; then
      echo "Failed to find clice binary!"
      exit 1
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
