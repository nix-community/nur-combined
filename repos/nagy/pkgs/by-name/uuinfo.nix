{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uuinfo";
  version = "0.8.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Racum";
    repo = "uuinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-47vGr5z3/kSFdqmzdscC/Domsq/EKQNs8rHf1cEOHPg=";
  };

  cargoHash = "sha256-HF9eJ/AQJDQUQeDLuXV37UD4ML2I6ZiToSRV0pFTf3U=";

  # Integration tests hardcode target/debug/uuinfo but Nix builds in release mode
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A tool to debug unique identifiers (UUID, ULID, Snowflake, etc";
    homepage = "https://github.com/Racum/uuinfo";
    changelog = "https://github.com/Racum/uuinfo/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "uuinfo";
  };
})
