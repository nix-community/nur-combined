{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  zstd,
  unstableGitUpdater,
}:
rustPlatform.buildRustPackage {
  pname = "moss";
  version = "unstable-2024-01-29";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "40073f75ef4c2bc638abaf4e5b5572cb54282dc0";
    hash = "sha256-RqzWU7OQTtIFiCGYzod09FKP6EuhsIa1ETI6d7p2Cgo=";
  };

  cargoHash = "sha256-nKUnTqJo1BrJ8ohOXahwBAOslnp8R5myiO1LxIsHqAE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    mainProgram = "moss";
    description = "The safe, fast and sane package manager for Linux";
    homepage = "https://github.com/serpent-os/moss-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [federicoschonborn];
  };
}
