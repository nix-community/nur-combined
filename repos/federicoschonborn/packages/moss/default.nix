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
  version = "unstable-2023-12-10";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "7da2b5c999afce75c57a7f7e3953cbcc92cbcdcb";
    hash = "sha256-4aLCBlkjJ3baXn7HEjNYi2fkrXDO5yNrZyK42kQduag=";
  };

  cargoHash = "sha256-FfvCYk9ggpbPXldm7hYSupPVapbMXbJej+luypMvbL0=";

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
