{
  lib,
  fetchFromGitHub,
  rustPlatform,
  unstableGitUpdater,
}:

rustPlatform.buildRustPackage rec {
  pname = "slatedb-nbd";
  version = "0-unstable-2025-08-17";

  src = fetchFromGitHub {
    owner = "john-parton";
    repo = "slatedb-nbd";
    rev = "91ec104e5482f9af25aa3151e6ac9f58ee00a1ba";
    hash = "sha256-2hWJM2EW38YZ4Ayuj7516M6B007TqPGbQTmgMv1PIrs=";
  };

  cargoHash = "sha256-M1x5NW65Ns4mgHfDPGiDtX27AhE/h+t2gUupN5CrRnA=";

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "NBD binding over SlateDB with minimal abstractions";
    homepage = "https://github.com/john-parton/slatedb-nbd";
    license = lib.licenses.gpl2Only;
    mainProgram = "slatedb-nbd";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.linux;
  };
}
