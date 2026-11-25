{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bazel_9,
  cacert,
  curl,
  apple-sdk,
  python3,
  nodejs,
  zlib,
  patchelf,
  writeShellApplication,
  git,
  nix,
}:

# clice needs its own LLVM/Clang fork (xclang) because it depends on internal
# Clang AST/indexing APIs and ThinLTO bitcode that diverge from upstream LLVM.
# Upstream nixpkgs closed PR #544899 (issue #371320) because packaging xclang
# from source is not supported there. To keep the build hermetic and
# reproducible:
#
# 1. xclang and the external dependencies are downloaded once into the `deps`
#    fixed-output derivation with `bazel vendor`, then pinned via VENDOR.bazel.
# 2. The real build runs offline with `--vendor_dir` pointing at `deps`, so it
#    never needs network access.
stdenv.mkDerivation (
  finalAttrs:
  let
    # The vendored tree carries the prebuilt xclang toolchain and the CMake and
    # Python shims of the host that produced it, so every supported platform has
    # its own tree and hash. This cannot live in the derivation attributes,
    # which are coerced to strings.
    depsHashes = {
      x86_64-linux = "sha256-VXhhwGH4xfOBQ4Pb64yeg/7rGYv/BufekWvLmXlw1W0=";
      aarch64-darwin = "sha256-MSZLrZPZV9p4YwuqtFGIGJ0RrpUktZz5LJkG79cYXxg=";
    };

    # Commit of the gh-pages branch of clice-io/bazel that `deps` is vendored
    # from. The branch is rewritten on every clice release, so a branch URL
    # would make the fixed-output hash stale within a day; the commit keeps the
    # build reproducible. Bump it together with the source revision.
    registryRev = "aea68cb2dd021c9c84a481beb79377390d55f10f";

    # The darwin build cannot listen in the sandbox (--batch), and its link
    # actions cache ThinLTO output in $TMPDIR. The link action does not inherit
    # the SDK from the environment, so the SDK is passed to the linker itself
    # (otherwise libSystem, the frameworks and the rest of the system libraries
    # cannot be found: the driver would ask xcrun, which the build does not
    # have). The toolchain's default libraries include -lz, which the macOS SDK
    # does not ship, so zlib's is searched instead. Substituted into a command
    # line, so the flags must stay on one line.
    darwinBazelFlags = lib.optionalString stdenv.hostPlatform.isDarwin (
      lib.concatStringsSep " " [
        "--sandbox_writable_path=$TMPDIR/xclang-thinlto"
        "--linkopt=-isysroot"
        "--linkopt=${apple-sdk.sdkroot}"
        "--linkopt=-L${lib.getLib zlib}/lib"
      ]
    );
  in
  {
    pname = "clice";
    version = "1.1.2026112310";

    src = fetchFromGitHub {
      owner = "clice-io";
      repo = "clice";
      tag = "v${finalAttrs.version}";
      hash = "sha256-K6P+VhUIzNAsQHiO2nhLF0AGIrNnAiHem9JFBE7OG6Y=";
    };

    deps = stdenvNoCC.mkDerivation {
      name = "clice-deps-${finalAttrs.version}";
      src = finalAttrs.src;

      nativeBuildInputs = [
        bazel_9
        python3
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        cacert
        curl
      ];

      strictDeps = true;

      # Use the Bazel packaged by Nix instead of the version selected by
      # upstream's .bazelversion; vendoring and compilation must agree.
      env.USE_BAZEL_VERSION = bazel_9.version;

      buildPhase = ''
        runHook preBuild

        export HOME=$TMPDIR
        export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
        mkdir -p $TMPDIR/xclang-thinlto

        ${lib.optionalString stdenv.hostPlatform.isLinux ''
          # Upstream caches ThinLTO output in /var/tmp, which the build sandbox
          # does not provide.
          sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc
        ''}

        ${lib.optionalString stdenv.hostPlatform.isDarwin ''
          # bazel.clice.io is a GitHub Pages site, published from the gh-pages
          # branch of clice-io/bazel. Some networks cannot reach GitHub Pages
          # over TLS, so fetch the published registry from codeload and use it
          # as the first registry. The tarball is pinned by the commit whose
          # registry `deps` was vendored from, so the fixed-output hash stays
          # reproducible.
          export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
          curl -fsSL -o $TMPDIR/clice-registry.tar.gz \
            https://codeload.github.com/clice-io/bazel/tar.gz/${registryRev}
          mkdir -p $TMPDIR/clice-registry
          tar -xzf $TMPDIR/clice-registry.tar.gz -C $TMPDIR/clice-registry --strip-components=1
          sed -i -e "s|https://bazel.clice.io/|file://$TMPDIR/clice-registry/|g" bazel/clice.bazelrc
        ''}

        # Fetch all external repositories from the network.
        bazel vendor -c opt --config=RelWithDebInfo //... --vendor_dir=$out

        ${lib.optionalString stdenv.hostPlatform.isDarwin ''
          # The main build expects the vendored registry index under
          # _registries/bazel.clice.io, but Bazel only keeps the registry files
          # it fetched while resolving, so modules of the clice registry can be
          # missing (Bazel vendors every registry under the first one's name).
          # Merge the whole published registry into it.
          if [ -d "$out/_registries" ] && [ ! -e "$out/_registries/bazel.clice.io" ]; then
            set -- $out/_registries/*
            mv "$1" "$out/_registries/bazel.clice.io"
          fi
          mkdir -p "$out/_registries/bazel.clice.io/modules"
          cp -R $TMPDIR/clice-registry/modules/. "$out/_registries/bazel.clice.io/modules/"
        ''}

        # Pin every vendored repository so that rewriting the registry URLs in
        # the real build does not invalidate them.
        for d in "$out"/*; do
          [ -d "$d" ] || continue
          repo=$(basename "$d")
          case "$repo" in
            _registries|bazel-external|@*.marker) continue ;;
          esac
          # The directory name is the canonical repository name, while the
          # pin() command needs the @@ prefix.
          echo "pin(\"@@$repo\")" >>"$out/VENDOR.bazel"
        done

        # Drop store references from vendored files (e.g. marker files holding
        # tool paths) so the output only depends on the vendored content.
        grep -rl "/nix/store" "$out" | while IFS= read -r f; do
          sed -i -E 's|/nix/store/[a-z0-9]{32}-[^/]+|/dummy|g' "$f"
        done

        runHook postBuild
      '';

      # The vendor directory is the output, so there is nothing to install or
      # fix up.
      dontFixup = true;
      installPhase = "true";

      outputHashMode = "recursive";
      outputHash =
        depsHashes.${stdenv.hostPlatform.system}
          or (throw "clice: no vendored dependency hash for ${stdenv.hostPlatform.system}");
    };

    nativeBuildInputs = [
      bazel_9
      python3
      nodejs
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      patchelf
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # The SDK the link is given as its sysroot.
      apple-sdk
    ];

    buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ zlib ];

    strictDeps = true;

    env.USE_BAZEL_VERSION = bazel_9.version;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1

      # Point the registry lines at the vendored registries.
      sed -i -e "s|https://bazel.clice.io/|file://${finalAttrs.deps}/_registries/bazel.clice.io|g" bazel/clice.bazelrc
      sed -i -e "s|https://bcr.bazel.build/|file://${finalAttrs.deps}/_registries/bcr.bazel.build|g" bazel/clice.bazelrc

      # Copy the vendor directory with a plain copy (no hardlinks) so it works
      # across filesystems. Bazel deletes the .marker files of pinned
      # repositories, which crashes if the directory is a read-only store path.
      cp -R ${finalAttrs.deps} $TMPDIR/vendor
      chmod -R u+w $TMPDIR/vendor

      # The ThinLTO cache has to be written where the action sandbox allows it.
      # Marker files are what Bazel matches a vendored repository against, so
      # they are left alone: rewriting one drops its pin and makes Bazel fetch
      # the repository again, which the build has no network for.
      mkdir -p $TMPDIR/xclang-thinlto
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc
      ''}
      find $TMPDIR/vendor -type f ! -name '*.marker' -exec sed -i \
        -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" \
        -e "s|/nix/var/nix/builds/[^/]*/xclang-thinlto|$TMPDIR/xclang-thinlto|g" {} +

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        # Patch the interpreter of the prebuilt ELF binaries in the vendored
        # toolchain. autoPatchelfHook cannot be used here: it would add glibc
        # and the rest of the closure to every vendored binary.
        dynamic_linker="$(cat $NIX_CC/nix-support/dynamic-linker)"
        for bin in $TMPDIR/vendor/xclang*x86_64*/bin/* $TMPDIR/vendor/rules_python*x86_64*/bin/python3*; do
          # The bin directories also hold .cfg files and wrapper scripts.
          if [ -f "$bin" ] && [ ! -L "$bin" ] \
            && [ "$(head -c 4 "$bin" | od -An -tx1 | tr -d ' \n')" = 7f454c46 ]; then
            patchelf --set-interpreter "$dynamic_linker" "$bin"
          fi
        done
      ''}

      # The darwin build sandbox forbids listening sockets, which the Bazel
      # server needs; --batch runs the build without starting it. Nix's SDK
      # ships text-based stubs only, whose system reexports are not in the
      # store, so system symbols are bound at load time, as the Darwin stdenv
      # does.
      bazel ${lib.optionalString stdenv.hostPlatform.isDarwin "--batch"} build -c opt --config=RelWithDebInfo //:bin/clice --vendor_dir=$TMPDIR/vendor ${darwinBazelFlags}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # The target is //bin:clice, so the binary is below the target's bin/ under
      # the symlink prefix. The macOS link writes a dSYM next to it, whose DWARF
      # file is also called clice, so the search below skips it.
      if [ -f build/RelWithDebInfo/bin/bin/clice ]; then
        install -Dm755 build/RelWithDebInfo/bin/bin/clice "$out/bin/clice"
      else
        find "$TMPDIR" -type f -name clice -perm -u+x ! -path "*.dSYM/*" \
          -exec install -Dm755 {} "$out/bin/clice" \; -quit
      fi

      if [ ! -x "$out/bin/clice" ]; then
        echo "Failed to find the clice binary!" >&2
        exit 1
      fi

      if [ -d build/RelWithDebInfo/lib ]; then
        cp -r build/RelWithDebInfo/lib "$out/lib"
      fi

      runHook postInstall
    '';

    passthru = {
      inherit (finalAttrs) deps;
      updateScript = writeShellApplication {
        name = "update-clice";
        runtimeInputs = [
          python3
          git
          nix
        ];
        text = ''
          cd "$(git rev-parse --show-toplevel)"
          export UPDATE_NIX_ATTR_PATH="clice"
          exec ${python3}/bin/python3 ${./update.py} "$@"
        '';
      };
    };

    meta = {
      description = "Next-generation C++ language server built on LLVM/Clang";
      homepage = "https://github.com/clice-io/clice";
      changelog = "https://github.com/clice-io/clice/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.asl20;
      maintainers = [ ];
      mainProgram = "clice";
      platforms = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      sourceProvenance = with lib.sourceTypes; [
        binaryNativeCode
        fromSource
      ];
    };
  }
)
