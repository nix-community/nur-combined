{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "duckdb-httpfs";
  version = "0-unstable-2026-10-19";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "duckdb";
    repo = "duckdb-httpfs";
    rev = "77392a72077a85897db2519fae11e2c0da972b8a";
    hash = "sha256-vdsNXoXFKBpnMacKssu3aEuEO4MV7GGyVR6BF4iZxao=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    curl
    openssl
  ];

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  installPhase = ''
    install -Dm644 build/release/extension/httpfs/httpfs.duckdb_extension -t $out
  '';

  meta = {
    description = "DuckDB HTTPFS extension";
    homepage = "https://github.com/duckdb/duckdb-httpfs";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
