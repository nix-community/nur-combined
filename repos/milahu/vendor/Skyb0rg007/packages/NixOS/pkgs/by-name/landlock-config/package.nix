{
  lib,
  stdenv,
  buildPackages,
  rustPlatform,
  fetchFromGitHub,
  cargo-c,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "landlock-config";
  version = "0-unstable-2026-07-16";

  src = fetchFromGitHub {
    owner = "landlock-lsm";
    repo = "landlockconfig";
    rev = "62ad0d66b8c97e5a3eb9c6e56809d828aaba614f";
    hash = "sha256-cfmu3P1ScREQTEOps1xkc40eEzXXigiwW4s0bXb8YMo=";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoHash = "sha256-nY6UxXk/CuPF03NdX/RviujFV4WhARIN/sQkgmVTfbs=";

  nativeBuildInputs = [
    cargo-c
  ];

  cargoBuildFlags = [
    "--package=llconfig"
  ];

  # The C API (cdylib/staticlib + header + pkg-config) is produced by the
  # `landlockconfig_ffi` crate via cargo-c which has no builtin
  # buildRustPackage support.
  postBuild = ''
    ${buildPackages.rust.envVars.setEnv} cargo cbuild --release --frozen \
      --package landlockconfig_ffi \
      --prefix=$out \
      --target ${stdenv.hostPlatform.rust.rustcTarget}
  '';

  postInstall = ''
    ${buildPackages.rust.envVars.setEnv} cargo cinstall --release --frozen \
      --package landlockconfig_ffi \
      --prefix=$out \
      --target ${stdenv.hostPlatform.rust.rustcTarget}
  '';

  meta = {
    homepage = "https://landlock.io";
    description = "Landlock configuration library";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    platforms = lib.platforms.linux;
  };
})
