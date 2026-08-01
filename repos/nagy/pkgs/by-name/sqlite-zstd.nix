{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sqlite-zstd";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "phiresky";
    repo = "sqlite-zstd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mWkgU60fPQsh6N+T1nn3a0HZhKlF4HapDSg1aFNvKx8=";
  };

  cargoHash = "sha256-OeHR3gdhunqhLnVeq/Ux52dzqDHCNUpuicjwsUV8urg=";

  # TODO use system provided sqlite and zstd
  # buildInputs = [ sqlite zstd ];

  meta = {
    description = "Transparent dictionary-based row-level compression for SQLite";
    homepage = "https://github.com/phiresky/sqlite-zstd";
    license = lib.licenses.lgpl3Plus;
  };
})
