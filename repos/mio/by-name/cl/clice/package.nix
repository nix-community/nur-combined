{
  lib,
  stdenv,
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

# Note regarding upstream Nixpkgs PR #544899 and Issue #371320:
# clice requires its own LLVM/Clang fork (xclang) because it depends on internal
# Clang AST / indexing APIs and ThinLTO bitcode that diverge from upstream LLVM.
# Upstream nixpkgs closed PR #544899 because packaging xclang from source is not
# yet supported upstream. To achieve a hermetic and reproducible build in Nix:
# 1. External dependencies and xclang are fetched in a fixed-output derivation (`deps`)
#    via Bazel's vendor mode and pinned via VENDOR.bazel.
# 2. The main build runs completely offline with `--vendor_dir` pointing to `deps`,
#    preventing any network access during compilation.
stdenv.mkDerivation (
  finalAttrs:
  let
    # The vendored tree carries the prebuilt xclang toolchain and the CMake/
    # Python shims of the host, so every platform vendors a different tree and
    # needs its own hash. Kept outside the derivation attributes, which are
    # coerced to strings.
    depsHashes = {
      x86_64-linux = "sha256-Lt6+2wdjQEnoNaT8PO5PfyLuDt5jQOiWGuR0M6TVFC4=";
      aarch64-darwin = "sha256-uAMod+qlqhfHAyjtsULDcZoVdBvEAxv5OJbVGGFR7WY=";
    };

    # Commit of the gh-pages branch of clice-io/bazel that `deps` is vendored
    # from. The branch is rewritten on every clice release, so a branch URL would
    # make the fixed-output hash stale within a day; the commit keeps the build
    # reproducible. Bump it together with the hash when updating clice.
    registryRev = "55895474675dcf8dddb284e0471898fa4f1f5902";

    # Extra flags of the darwin build: the server cannot listen in the sandbox
    # (--batch) and links cache ThinLTO output in $TMPDIR. The link action does
    # not inherit the SDK from the environment, so the SDK is named to the
    # linker itself (without it, libSystem, the frameworks and the rest of the
    # system libraries cannot be found, as the driver asks xcrun, which the
    # build does not have). The toolchain's default libraries include -lz, which
    # the macOS SDK does not ship, so zlib's is searched instead.
    # One line: the flags are substituted into a command line, where a newline
    # would end the command.
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
    version = "0.1.2026102908";

    src = fetchFromGitHub {
      owner = "clice-io";
      repo = "clice";
      tag = "v${finalAttrs.version}";
      hash = "sha256-zw9DWCcr230LMwY4P4Va8QXnogpk04CDA5+fVU0vG9w=";
    };

    deps = stdenv.mkDerivation {
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

      dontCheckForBrokenSymlinks = true;

      buildPhase = ''
                runHook preBuild

                export HOME=$TMPDIR
                export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
                mkdir -p $TMPDIR/xclang-thinlto
        ${lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
          sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc || true
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

                # Fetch all external repositories from the network
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

      # The ThinLTO cache has to be written in a place the action sandbox allows.
      # Marker files are what Bazel matches a vendored repository against, so they
      # are left as they are: rewriting one drops its pin and has Bazel fetch the
      # repository again, which the build has no network for.
      mkdir -p $TMPDIR/xclang-thinlto
      ${lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
        sed -i -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" bazel/clice.bazelrc
      ''}
      find $TMPDIR/vendor -type f ! -name '*.marker' -exec sed -i \
        -e "s|/var/tmp/xclang-thinlto|$TMPDIR/xclang-thinlto|g" \
        -e "s|/nix/var/nix/builds/[^/]*/xclang-thinlto|$TMPDIR/xclang-thinlto|g" {} + 2>/dev/null || true

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        # Patch interpreter on prebuilt ELF binaries inside vendored toolchains
        dynamic_linker="$(cat $NIX_CC/nix-support/dynamic-linker)"
        for bin in $TMPDIR/vendor/xclang*x86_64*/bin/* $TMPDIR/vendor/rules_python*x86_64*/bin/python3*; do
          if [ -f "$bin" ] && [ ! -L "$bin" ]; then
            patchelf --set-interpreter "$dynamic_linker" "$bin" 2>/dev/null || true
          fi
        done
      ''}

      # The darwin build sandbox forbids listening sockets, which the Bazel
      # server needs; --batch runs the build without starting it. The link
      # actions write their ThinLTO cache in $TMPDIR, which the action sandbox
      # has to be told about. Nix's SDK ships text-based stubs only, whose
      # system reexports are not in the store, so system symbols are bound at
      # load time, as the Darwin stdenv does.
      bazel ${lib.optionalString stdenv.hostPlatform.isDarwin "--batch"} build -c opt --config=RelWithDebInfo //:bin/clice --vendor_dir=$TMPDIR/vendor ${darwinBazelFlags}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      # The target is //bin:clice, so the binary is below the target's bin/ under
      # the symlink prefix. The macOS link writes a dSYM next to it, whose DWARF
      # file is also called clice, so the search below skips it.
      if [ -f build/RelWithDebInfo/bin/bin/clice ]; then
        install -Dm755 build/RelWithDebInfo/bin/bin/clice "$out/bin/clice"
      else
        find "$TMPDIR" -type f -name clice -perm -u+x ! -path "*.dSYM/*" -exec cp -L {} "$out/bin/clice" \; -quit
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
      updateScript = writeShellApplication {
        name = "update-clice";
        runtimeInputs = [
          python3
          git
          nix
        ];
        text = ''
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
