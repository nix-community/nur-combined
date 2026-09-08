{
  lib,
  buildGoModule,
  fetchFromGitHub,
  iproute2,
}:

buildGoModule (finalAttrs: {
  pname = "sonar";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "raskrebs";
    repo = "sonar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JUb5oTpFynCjys66uEgrqUoQtqNnI1EM6+GFh/4jpKU=";
  };

  nativeBuildInputs = [
    iproute2
  ];

  vendorHash = "sha256-umFMWI3j1KVzEYnBTiq8ulMLRnxM6i0s7zYEBAjnKfc=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/raskrebs/sonar/internal/selfupdate.Version=v${finalAttrs.version}"
  ];

  doCheck = false;

  meta = {
    description = "CLI tool for inspecting and managing services listening on localhost ports";
    homepage = "https://github.com/raskrebs/sonar";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sonar";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
