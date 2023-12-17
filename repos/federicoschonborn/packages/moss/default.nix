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
  version = "unstable-2023-12-14";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "f04d77b81407a294c05147a8205ab51d0692ca64";
    hash = "sha256-h8Bu6YL+NO1swyEQt610JveBb6NuCpFpicw6HsP0O/k=";
  };

  cargoHash = "sha256-tmzPHP79W5BfUTrh76aQ/48zvaISkRw3Xlf+ZWn5A14=";

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
