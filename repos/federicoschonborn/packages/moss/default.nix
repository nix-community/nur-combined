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
  version = "unstable-2023-11-11";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "93a5a1ef2ea738e3429d07e545d53fef26804054";
    hash = "sha256-WlHLcvqpyAzeWazltfs5h3QjandTaOgc093egPmBuwY=";
  };

  cargoHash = "sha256-e+UmqS2zIMNiqob3OKxay5cnxxfx7+9gfG2oaF2TAjo=";

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
