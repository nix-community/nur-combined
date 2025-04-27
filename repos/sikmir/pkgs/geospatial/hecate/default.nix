{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "hecate";
  version = "0.87.0";

  src = fetchFromGitHub {
    owner = "Hecate";
    repo = "Hecate";
    tag = "v${version}";
    hash = "sha256-X+49Mnls5xK6ag1QcvEm0GvLPmvcRBwNn/1vnC9GJO8=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  useFetchCargoVendor = true;
  cargoHash = "sha256-DIsvqtccOJD54LHjQdq+jQq3d25/EqjS/Jx4Bz/Pmd0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  doCheck = false;

  meta = {
    description = "Fast Geospatial Feature Storage API";
    homepage = "https://github.com/Hecate/Hecate";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isLinux;
  };
}
