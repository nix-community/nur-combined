{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  getopt,
  llvmPackages,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libpathrs";
  version = "0.2.6";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cyphar";
    repo = "libpathrs";
    # upstream tagged the wrong commit
    # tag = "v${finalAttrs.version}";
    rev = "941f5488a93811bc6c00f6aa4f8c29095252f33b";
    hash = "sha256-ZCCsrWZ1tgjxf9CNFxzbHGEkecgSuQjn2GeK7baTfqo=";
  };

  cargoHash = "sha256-Bizqdc0FliqmEl5dW2JwWNPyaNwP8ZCy3i4um6Zc4QM=";

  nativeBuildInputs = [
    getopt
    # build.rs links the cdylib with -fuse-ld=lld
    llvmPackages.bintools
  ];

  env.RUSTFLAGS = "-C panic=abort";

  buildPhase = ''
    runHook preBuild

    LIBPATHRS_CAPI_BUILDMODE=cdylib cargo rustc \
      -j "$NIX_BUILD_CORES" \
      --offline \
      --target ${stdenv.hostPlatform.rust.rustcTargetSpec} \
      --profile release \
      --features capi \
      --lib \
      --crate-type cdylib

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    bash ./install.sh \
      --prefix="$out" \
      --libdir="$out/lib" \
      --disable-static \
      --rust-target=${stdenv.hostPlatform.rust.cargoShortTarget}

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Safe path resolution within untrusted directories";
    license = lib.licenses.OR [
      lib.licenses.mpl20
      lib.licenses.lgpl3Plus
    ];
    homepage = "https://github.com/cyphar/libpathrs";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
