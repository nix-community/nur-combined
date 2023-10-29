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
  version = "unstable-2023-10-29";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "f486d632c9ffc7ad374ff00dfa0b1cee49f3c448";
    hash = "sha256-Pc7jrco5Cb5zIVpLKmUrSBRbYVACDSRUmFDBvE94Orc=";
  };

  cargoHash = "sha256-Gypdh7Gnr+iWs4Qavb1hgL9jZ3oQlbWGjaGV30rnSb0=";

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
