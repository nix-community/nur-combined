{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "lnshot";
  version = "0.1.3-unstable-2026-01-01";

  src = fetchFromGitHub {
    owner = "ticky";
    repo = pname;
    rev = "8aaaa09eabb02bb594565c68420087d16595c234";
    hash = "sha256-xcQfdSEsa8STr5gp+qZvHXRPNN2PKQCBksRJ+/e77v8=";
  };

  cargoHash = "sha256-L3a1Y+mnjDiexRTSnbNOhQ3+HFOm06xRNsdDm544miM=";

  meta = with lib; {
    description = "Symlink your Steam screenshots to a sensible place";
    homepage = "https://github.com/ticky/lnshot";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "lnshot";
  };
}
