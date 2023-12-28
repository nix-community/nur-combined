{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, sqlite
, zstd
, unstableGitUpdater
}:

rustPlatform.buildRustPackage {
  pname = "moss";
  version = "unstable-2023-12-17";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "bb68b260f7a83be86f38179e2139659feee96d56";
    hash = "sha256-cmUbpDIf5sepeeJvNGgb9D1+yM1RFUwZKQU6YB0v+PY=";
  };

  cargoHash = "sha256-1CiWZ7CAtlUfmfgdTRN5qxAN0Rodrgq7PMaW4j2NwbI=";

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
  };
}
