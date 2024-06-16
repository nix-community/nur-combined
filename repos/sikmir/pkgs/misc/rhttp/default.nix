{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "rhttp";
  version = "0-unstable-2024-04-22";

  src = fetchFromGitHub {
    owner = "1buran";
    repo = "rHttp";
    rev = "783b7a8cc4a210963a1cab6c502c2515054d66ba";
    hash = "sha256-ZirlRBKQq0lUP4STHYWRd/A5joFLTFXikhqttRiYZ8g=";
  };

  vendorHash = "sha256-NR1q44IUSME+x1EOcnXXRoIXw8Av0uH7iXhD+cdd99I=";

  meta = {
    description = "REPL for HTTP";
    homepage = "https://github.com/1buran/rHttp";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "rhttp";
  };
}
