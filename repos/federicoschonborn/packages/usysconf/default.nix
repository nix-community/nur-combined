{ lib
, rustPlatform
, fetchFromGitHub
, rustc
, unstableGitUpdater
}:

rustPlatform.buildRustPackage {
  pname = "usysconf";
  version = "unstable-2023-11-01";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "usysconf-rs";
    rev = "22150ddac0165a31f8096155386e64da632f9c16";
    hash = "sha256-+AQVNNdhzFPRB5UjsntDazRr1mV4qsINptKEMYIfvd4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "dag-0.1.0" = "sha256-FIdBYIXBEMkMfW7znRClXwExzPtgaomJqTqlH+HG1RI=";
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
    broken = lib.versionOlder rustc.version "1.70";
  };
}
