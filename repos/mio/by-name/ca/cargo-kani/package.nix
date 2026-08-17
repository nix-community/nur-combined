{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  zlib,
  gcc,
}:

let
  version = "0.67.0";

  # Kani 0.67.0 is compiled against this specific rustc nightly
  rustc-nightly = fetchzip {
    url = "https://static.rust-lang.org/dist/2025-11-21/rustc-nightly-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-HXV2UI9JC2InkUWj6JJPyngScRgBTfiiP+j4eQh+bSg=";
  };
in
stdenv.mkDerivation rec {
  pname = "cargo-kani";
  inherit version;

  src = fetchzip {
    url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-I+GKPEWYXPZimCN79IB9dKiY8+NhP4Y8JjAS7R00XMs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    gcc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/
    
    # Kani binaries (like kani-compiler) depend on librustc_driver and libLLVM 
    # which are only found in the specific rustc nightly release.
    # We copy them so autoPatchelfHook can link against them.
    cp -r ${rustc-nightly}/rustc/lib/*.so* $out/lib/

    # Create cargo-kani and kani symlinks that point to kani-driver
    ln -s $out/bin/kani-driver $out/bin/cargo-kani
    ln -s $out/bin/kani-driver $out/bin/kani

    # Kani expects a full Rust toolchain in $out/toolchain/bin/
    # We create simple wrapper scripts that forward to the environment's tools.
    mkdir -p $out/toolchain/bin
    
    cat > $out/toolchain/bin/cargo <<EOF
    #!/bin/sh
    exec cargo "\$@"
    EOF
    chmod +x $out/toolchain/bin/cargo

    cat > $out/toolchain/bin/rustc <<EOF
    #!/bin/sh
    exec rustc "\$@"
    EOF
    chmod +x $out/toolchain/bin/rustc

    runHook postInstall
  '';

  meta = with lib; {
    description = "Kani Rust Verifier";
    homepage = "https://model-checking.github.io/kani/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
