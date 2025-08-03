{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hecate";
  version = "0.87.0";

  src = fetchFromGitHub {
    owner = "Hecate";
    repo = "Hecate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X+49Mnls5xK6ag1QcvEm0GvLPmvcRBwNn/1vnC9GJO8=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-DIsvqtccOJD54LHjQdq+jQq3d25/EqjS/Jx4Bz/Pmd0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  doCheck = false;

  meta = {
    description = "Fast Geospatial Feature Storage API";
    homepage = "https://github.com/Hecate/Hecate";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isLinux;
  };
})
