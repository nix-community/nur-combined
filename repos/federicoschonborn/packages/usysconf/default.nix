{ lib
, rustPlatform
, fetchFromGitHub
, unstableGitUpdater
}:

rustPlatform.buildRustPackage {
  pname = "usysconf";
  version = "unstable-2023-11-24";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "usysconf-rs";
    rev = "538cca9b1f5f72ec9f643778ce04dc2cba505d57";
    hash = "sha256-jxj/QobdlpEwqX5hS5vo80WFqLFmKjgmZHxUHgyNCFc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "dag-0.1.0" = "sha256-IKTVDCbjIYcLB8LUABLWzR9PqC1HXkpu51TpCOAANBg=";
    };
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "usysconf";
    description = "Usysconf - now with extra rust";
    homepage = "https://github.com/serpent-os/usysconf-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
