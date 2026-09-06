{
  lib,
  buildGoModule,
  fetchFromGitHub,
  iproute2,
}:

buildGoModule (finalAttrs: {
  pname = "sonar";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "raskrebs";
    repo = "sonar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0uFN0C+r6BO4sqfC+A5BxeTZhOeHQvYmnD/BxsFCbbE=";
  };

  nativeBuildInputs = [
    iproute2
  ];

  vendorHash = "sha256-ojAqeq3SjUgLUsK7t1C+ryWokt1A/6g11UXSX3zKVH4=";

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
