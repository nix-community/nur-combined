{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "goto";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "grafviktor";
    repo = "goto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UxOxOdT5HZM8u3gSXKt5OygSJz8set5qTJnXdGTpPo8=";
  };

  vendorHash = "sha256-ngtjhDzZFOcq7bE6JtA7/xfinfRX2qB0ncE+MCgJTTQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "A simple SSH manager";
    homepage = "https://github.com/grafviktor/goto";
    license = lib.licenses.mit;
    mainProgram = "goto";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
