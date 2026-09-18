{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  makeRustPlatform,
}:

let
  fenix_repo = pkgs.fetchzip {
    url = "https://github.com/nix-community/fenix/archive/main.tar.gz";
    hash = "sha256-37asD+JKFnedthzsuGP8mDgxCzjNePJVfMAVzYWIMfs=";
  };
  fenix = import fenix_repo { inherit pkgs; };
  toolchain_components = fenix.targets.x86_64-unknown-linux-gnu.toolchainOf {
    channel = "nightly";
    date = "2026-08-21";
    sha256 = "sha256-PDDMZVp1SdCzABXNAy+Unocj2lrQOfZy0EUgu66k520=";
  };
  toolchain = fenix.combine [
    toolchain_components.rustc
    toolchain_components.cargo
    toolchain_components.rust-std
    toolchain_components.rustc-dev
    toolchain_components.llvm-tools-preview
    toolchain_components.rust-src
  ];

  # Kani 0.67.0
  version = "0.68.0";

  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "cargo-kani";
  inherit version;

  src = fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    rev = "kani-${version}";
    fetchSubmodules = true;
    hash = "sha256-OwjC0I06KxFxnQ4J/599v6ktZKqWgE3Kn/SY8hSk6DY=";
  };

  cargoHash = "sha256-ZXeYvQu/x3W1CCb/urUtMe4sNr9j6t17igwL8glOGlM=";

  env = {
    RUSTUP_HOME = "dummy";
    RUSTUP_TOOLCHAIN = "dummy";
  };

  cargoPatches = [
    ./cargo-lock.patch
  ];

  nativeBuildInputs = [
    pkg-config
    pkgs.cbmc
    pkgs.kissat
  ];

  buildInputs = [
    openssl
    zlib
  ];

  preBuild = ''
    echo "Creating fake sysroot to fix lockfile conflicts..."
    REAL_SYSROOT=$(rustc --print sysroot)
    export FAKE_SYSROOT=$TMPDIR/fake-sysroot
    mkdir -p $FAKE_SYSROOT/lib/rustlib/src
    
    # Link all stuff from real sysroot
    for item in $REAL_SYSROOT/*; do
        if [ "$item" != "$REAL_SYSROOT/lib" ]; then
            ln -s $item $FAKE_SYSROOT/
        fi
    done
    mkdir -p $FAKE_SYSROOT/lib/rustlib
    for item in $REAL_SYSROOT/lib/*; do
        if [ "$item" != "$REAL_SYSROOT/lib/rustlib" ]; then
            ln -s $item $FAKE_SYSROOT/lib/
        fi
    done
    for item in $REAL_SYSROOT/lib/rustlib/*; do
        if [ "$item" != "$REAL_SYSROOT/lib/rustlib/src" ]; then
            ln -s $item $FAKE_SYSROOT/lib/rustlib/
        fi
    done
    
    # Copy rust-src and remove lockfile
    cp -r $REAL_SYSROOT/lib/rustlib/src/rust $FAKE_SYSROOT/lib/rustlib/src/rust
    chmod -R +w $FAKE_SYSROOT/lib/rustlib/src/rust
    
    # Remove std's Cargo.lock and replace it with Kani's modified lockfile
    rm -f $FAKE_SYSROOT/lib/rustlib/src/rust/library/Cargo.lock
    cp Cargo.lock $FAKE_SYSROOT/lib/rustlib/src/rust/library/Cargo.lock
    
    # Inject a wrapper into build-kani to intercept sysroot
    cat << 'EOF_PATCH' > $TMPDIR/sysroot.patch
--- tools/build-kani/src/sysroot.rs
+++ tools/build-kani/src/sysroot.rs
@@ -156,6 +156,9 @@
     ];
     rustc_args.extend_from_slice(extra_rustc_args);
+    let wrapper_path = compiler_path.with_extension("wrapper");
+    std::fs::write(&wrapper_path, format!("#!/bin/sh\nif [ \"$1\" = \"--print\" ] && [ \"$2\" = \"sysroot\" ]; then echo \"{}\"; elif [ \"$1\" = \"--print=sysroot\" ]; then echo \"{}\"; else exec {} \"$@\"; fi\n", std::env::var("FAKE_SYSROOT").unwrap(), std::env::var("FAKE_SYSROOT").unwrap(), compiler_path.display())).unwrap();
+    std::process::Command::new("chmod").arg("+x").arg(&wrapper_path).status().unwrap();
     let mut cmd = Command::new("cargo")
         .env("CARGO_ENCODED_RUSTFLAGS", rustc_args.join("\x1f"))
-        .env("RUSTC", compiler_path)
+        .env("RUSTC", wrapper_path)
         .args(args)
EOF_PATCH
    patch -p0 < $TMPDIR/sysroot.patch
  '';

  buildPhase = ''
    runHook preBuild
    export CARGO_OFFLINE=true
    cargo run --offline -p build-kani -- bundle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    tar -xzf kani-0.68.0-*.tar.gz -C $out --strip-components=1

    # Remove proxy wrappers and symlink the real kani-driver
    rm -f $out/bin/cargo-kani $out/bin/kani
    ln -s $out/bin/kani-driver $out/bin/cargo-kani
    ln -s $out/bin/kani-driver $out/bin/kani
    mkdir -p $out/toolchain/bin $out/toolchain/lib
    ln -s ${toolchain}/lib/* $out/toolchain/lib/
    ln -s ${toolchain}/lib/*.so $out/lib/
    ln -s ${toolchain}/bin/cargo $out/toolchain/bin/cargo
    ln -s ${toolchain}/bin/rustc $out/toolchain/bin/rustc
    runHook postInstall
  '';

  meta = with lib; {
    description = "Kani Rust Verifier";
    homepage = "https://model-checking.github.io/kani/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
