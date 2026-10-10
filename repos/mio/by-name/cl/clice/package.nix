{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  buildFHSEnv,
  writeShellScriptBin,
  python3,
  nodejs,
  bash,
  removeReferencesTo,
}:

let
  bazel_9_bin = fetchurl {
    url = "https://github.com/bazelbuild/bazel/releases/download/9.2.0/bazel-9.2.0-linux-x86_64";
    hash = "sha256-g5Ex099AioWOG32vTs9nGo0oTLmH5e0q/CmbuI0Cg+A=";
    executable = true;
  };

  # Wrap bazel inside an FHS environment so it can execute without patchelf corruption
  bazel_env = buildFHSEnv {
    name = "bazel-env";
    targetPkgs = pkgs: with pkgs; [ gcc zlib python3 ];
    extraBwrapArgs = [ "--tmpfs" "/var" "--bind" "/tmp" "/var/tmp" ];
    runScript = "bash";
  };

  bazel_9 = writeShellScriptBin "bazel" ''
    mkdir -p /tmp/xclang-thinlto
    exec ${bazel_env}/bin/bazel-env -c '"$0" "$@"' ${bazel_9_bin} "$@"
  '';

  version = "0.1.2026100708";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    tag = "v${version}";
    hash = "sha256-8bjL/sB4WHrum1H8IDdL+P4msCzTBn92Ts2OuGhvV78=";
  };

  deps = stdenv.mkDerivation {
    name = "clice-deps";
    inherit src;
    
    nativeBuildInputs = [ bazel_9 python3 removeReferencesTo ];

    dontCheckForBrokenSymlinks = true;

    buildPhase = ''
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
    '';

    dontFixup = true;

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-9n/hk0U4lUBAwQ+BDYXFjPnV4zysk/Kzc7Qj6emk/4k=";
  };

in
stdenv.mkDerivation {
  pname = "clice";
  inherit version src;

  nativeBuildInputs = [ bazel_9 python3 nodejs ];

  buildPhase = ''
    export HOME=$TMPDIR
    export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
    
    # Rewrite registry lines to point to the local vendored registries
    sed -i -e "s|https://bazel.clice.io/|file://${deps}/_registries/bazel.clice.io|g" bazel/clice.bazelrc || true
    sed -i -e "s|https://bcr.bazel.build/|file://${deps}/_registries/bcr.bazel.build|g" bazel/clice.bazelrc || true

    # Copy vendor directory using standard copy (no hardlinks) so it works across filesystems.
    # Bazel attempts to delete .marker files for pinned repositories, which crashes
    # if the vendor directory is a read-only Nix store path.
    cp -R ${deps} $TMPDIR/vendor
    chmod -R u+w $TMPDIR/vendor

    bazel build -c opt --config=RelWithDebInfo //... --vendor_dir=$TMPDIR/vendor
  '';

  installPhase = ''
    mkdir -p $out/bin
    find $TMPDIR -name "clice" -executable -exec cp -L {} $out/bin/clice \;
    # Ensure it was copied
    if [ ! -f $out/bin/clice ]; then
      echo "Failed to find clice binary!"
      exit 1
    fi
  '';

  meta = with lib; {
    description = "Next-generation C++ language server built on LLVM/Clang";
    homepage = "https://github.com/clice-io/clice";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "clice";
  };
  passthru = { inherit deps; };
}
