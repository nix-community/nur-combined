{ lib
, rustPlatform
, fetchFromGitHub
, unstableGitUpdater
}:

rustPlatform.buildRustPackage {
  pname = "usysconf";
  version = "unstable-2023-12-09";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "usysconf-rs";
    rev = "3047d89865bc44c77da754ac8107ff157cb98f62";
    hash = "sha256-d3y2uzv4f8iyvQgan1YF5rrwbjXIWyzgiqc+5/XikEQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "dag-0.1.0" = "sha256-d0CLsSlrTZmaNkgNvYP4P26GEG+NsUvRYnjdnXb6ibM=";
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
