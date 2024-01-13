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
  version = "unstable-2024-01-06";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "29a536318cf9995662bac39ea42e425fca1e4181";
    hash = "sha256-hgJoMtt7PYlK6TnHZrJu9TML0HNHt8i4Ag0jtrlVDaw=";
  };

  cargoHash = "sha256-zPntkWeg51CES1SA9lgdUzLXdYa5A0C40KVubJdWM8E=";

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
