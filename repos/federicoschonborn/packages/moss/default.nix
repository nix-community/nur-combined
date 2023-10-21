{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, sqlite
, zstd
, unstableGitUpdater
, rustc
}:

rustPlatform.buildRustPackage {
  pname = "moss";
  version = "unstable-2023-10-19";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "c4825190fd4677f71b5b3af4c79fce248d71852f";
    hash = "sha256-/85y+KsBw+KpJ2dVnzcQtuC6w7Hg90AwhUjgGrnJj10=";
  };

  cargoHash = "sha256-QPRSODSMRwows5eRWnCGfiBLN9JVPbE44AUdx5uRpNM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "moss";
    description = "The safe, fast and sane package manager for Linux";
    homepage = "https://github.com/serpent-os/moss-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.70";
  };
}
