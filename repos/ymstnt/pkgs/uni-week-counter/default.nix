{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  pname = "uni-week-counter";
  version = "1.3.0-unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo =  "uni-week-counter";
    rev = "2c156dfa5b55cd5d782b1e03bd7bec6a6211ec8d";
    hash = "sha256-d2ncOL00Y6dZWuBPV7DFJtVKo6LQa1Sxghbn2Iah468=";
  };

  vendorHash = null;

  meta = {
    description = "University week counter API.";
    homepage = "https://github.com/ymstnt/uni-week-counter/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ymstnt ];
    platforms = lib.platforms.all;
    mainProgram = "uni-week-counter";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
