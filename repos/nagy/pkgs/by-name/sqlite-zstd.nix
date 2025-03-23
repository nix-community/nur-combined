{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sqlite-zstd";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "phiresky";
    repo = "sqlite-zstd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bl9CF/w6A1Ugz8t+8WimMNOGzysL4eiiu07d2+KND8k=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-pCLcCoVLnu4i0yO57T8V3D4WMKfSu3wgPKchx3jhviU=";

  # TODO use system provided sqlite and zstd
  # buildInputs = [ sqlite zstd ];

  meta = {
    description = "Transparent dictionary-based row-level compression for SQLite";
    homepage = "https://github.com/phiresky/sqlite-zstd";
    license = lib.licenses.lgpl3Plus;
  };
})
