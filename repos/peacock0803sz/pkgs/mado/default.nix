{ lib, buildGo125Module, fetchFromGitHub }:
let
  version = "1.0.1";
in
buildGo125Module {
  pname = "mado";
  inherit version;

  src = fetchFromGitHub {
    owner = "peacock0803sz";
    repo = "darwin-mado";
    tag = "v${version}";
    hash = "sha256-B80+pGn1kIqARix4T85Eww6woGHy1LeGd76OaAqhrRs=";
  };

  vendorHash = "sha256-RGfYVhSFb/fFrLJ6PwG4ZXLuHdWcdYm2LmLLU7flM/s=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/peacock0803sz/darwin-mado/cmd/mado/main.version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "窓; window - A CLI tool for managing macOS windows";
    homepage = "https://github.com/peacock0803sz/darwin-mado";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mado";
  };
}
