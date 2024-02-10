{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  zstd,
  unstableGitUpdater,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "moss";
  version = "unstable-2024-02-05";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss";
    rev = "4364e12dcda17aebc98d33c77bb052fb71584517";
    hash = "sha256-vDV9VO6X6A0+bWiXJdqdS4W/6pXYBwMhnk9QvxxGgwo=";
  };

  cargoHash = "sha256-TsDTjOS/ajQRU+urzNW6ztNll4oCJ51M5+IRtrRtLbY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "moss";
    description = "The safe, fast and sane package manager for Linux";
    homepage = "https://github.com/serpent-os/moss";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.74.0";
  };
}
