{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "acp";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Contextualist";
    repo = "acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FxpIfJ6WWWgaBQnTbvp0DqRrmPmT0ZUjueBFgJ24HAY=";
  };

  vendorHash = "sha256-Z7RfbOea1cKavbLqPMgWvez2mzvvjl0ll/ikotrWlbA=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildTag=${finalAttrs.version}"
  ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Make terminal personal file transfers as simple as `cp`";
    homepage = "https://github.com/Contextualist/acp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "acp";
  };
})
