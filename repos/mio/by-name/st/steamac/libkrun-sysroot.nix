{
  lib,
  stdenv,
  libkrunSrc,
  curl,
  cacert,
  xz,
  gnutar,
  coreutils,
}:

# libkrun's Makefile downloads a Debian bookworm sysroot (libc6, libc6-dev,
# libgcc-12-dev, linux-libc-dev) on macOS to cross-compile the guest init blob.
# Fetch it here so the main build stays offline.
stdenv.mkDerivation {
  name = "libkrun-linux-sysroot";

  src = libkrunSrc;

  nativeBuildInputs = [
    curl
    xz
    gnutar
    coreutils
  ];

  dontConfigure = true;
  # Data-only sysroot (Linux ELF libraries); Nix's fixup cannot patchelf them.
  dontFixup = true;

  __noChroot = true;

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export CURL_CA_BUNDLE=$SSL_CERT_FILE
    make linux-sysroot/.sysroot_ready DEBIAN_DIST=bookworm GCC_VERSION=12
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R linux-sysroot "$out/sysroot"
    rm -rf "$out/sysroot/.tmp"
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-EhL04pWl7HnBKn6cF3Q/hBVov7iyXvF13JPgvDiONx0=";

  meta = {
    description = "Debian sysroot used to cross-build libkrun's init blob";
    platforms = [ "aarch64-darwin" ];
  };
}
