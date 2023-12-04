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
  version = "unstable-2023-11-30";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "1072048c7e9fb35a976fc593d8d9b08290ca0b03";
    hash = "sha256-iNyn9hBk8W01Vh5yFg/1KAea6zIBEe7mqSQzYgDshzI=";
  };

  cargoHash = "sha256-GB2dpGc5j9RIHaOcbBZ20lIefOBeBaQnJ7UvDzydsSo=";

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
