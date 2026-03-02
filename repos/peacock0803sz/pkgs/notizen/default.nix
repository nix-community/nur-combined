{ lib, buildGo125Module, fetchFromGitHub }:
let
  version = "0.1.0";
in
buildGo125Module {
  pname = "notizen";
  inherit version;

  src = fetchFromGitHub {
    owner = "peacock0803sz";
    repo = "notizen";
    tag = "v${version}";
    hash = "sha256-nZFUGoNiTpKIDSV0arD19n/iCwHaHkioe2RDr/Zx1U0=";
  };

  vendorHash = "sha256-y8ZUtc70LFItESZsLtor/pd7vJusvCH4AwYzAl0y8u0=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/peacock0803sz/notizen/cmd/notizen/main.version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "A simple note-taking CLI";
    homepage = "https://github.com/peacock0803sz/notizen";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "notizen";
  };
}
