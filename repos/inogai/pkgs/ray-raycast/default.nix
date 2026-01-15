{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ray-raycast";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "pomdtr";
    repo = "ray";
    rev = "v${version}";
    hash = "sha256-CX4lD8CaK7d1hkJKjZoUOZeY/zK9j9oeqbFpgPvWeac=";
  };

  vendorHash = "sha256-JOrHlFyC7mlT5d0jmq/GgrVW05sqiPwUU8qGuVbfvI4=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A command line interface for Raycast";
    homepage = "https://github.com/pomdtr/ray";
    changelog = "https://github.com/pomdtr/ray/releases";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = "ray";
    platforms = lib.platforms.all;
  };
}
