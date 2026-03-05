{ lib, buildGo125Module, fetchFromGitHub }:
let
  version = "0.4.0";
in
buildGo125Module {
  pname = "mado";
  inherit version;

  src = fetchFromGitHub {
    owner = "peacock0803sz";
    repo = "darwin-mado";
    tag = "v${version}";
    hash = "sha256-w7SEgYEHYTeswzUvebo9YCgA0b1gI1NTF7tlZGBQkSc=";
  };

  vendorHash = "sha256-y8ZUtc70LFItESZsLtor/pd7vJusvCH4AwYzAl0y8u0=";

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
