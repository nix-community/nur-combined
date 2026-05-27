{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "sonar";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "raskrebs";
    repo = "sonar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rHc7uYk0Js/hvWntI/Kt4Wq6Pod4T1DnTjAeUDa0fv0=";
  };

  vendorHash = "sha256-komX1AmHt2NoF1x6xsNa2RFkfVzOXfYEMPhT0zwMxjw=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/raskrebs/sonar/internal/selfupdate.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "CLI tool for inspecting and managing services listening on localhost ports";
    homepage = "https://github.com/raskrebs/sonar";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sonar";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
