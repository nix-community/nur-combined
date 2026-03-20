{
  lib,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  go = pkgs.go;
  pname = "gitcredits";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Higangssh";
    repo = "gitcredits";
    rev = "v${version}";
    hash = "sha256-WubDra7945LtE2gxlqumlq0ie5jakT6Zv7f8qod+ZUs=";
  };

  vendorHash = "sha256-WKi++Ax+gVzhCqbUdOrgYZZiNeKGU3HqGlgRVZDtCvQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Turn your Git contributors into movie stars with a cinematic credits sequence";
    homepage = "https://github.com/Higangssh/gitcredits";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
