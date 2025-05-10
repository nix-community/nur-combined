{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule {
  name = "dockerfmt";
  version = "v0.3.7";

  src = fetchFromGitHub {
    owner = "reteps";
    repo = "dockerfmt";
    rev = "cca3c3003c46491de69552642ea01f56740d77c2";
    hash = "sha256-cNxPe0LOZyUxyw43fmTQeoxvXcT9K+not/3SvChBSx4=";
  };

  vendorHash = "sha256-fLGgvAxSAiVSrsnF7r7EpPKCOOD9jzUsXxVQNWjYq80=";

  ldflags = [];

  meta = with lib; {
    description = "Dockerfile formatter, and a modern version of dockfmt. Built on top of the internal buildkit parser.";
    mainProgram = "dockerfmt";
    homepage = "https://github.com/reteps/dockerfmt";
    license = licenses.mit;
  };
}
