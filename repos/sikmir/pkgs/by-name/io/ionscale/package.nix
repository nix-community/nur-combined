{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ionscale";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "jsiebens";
    repo = "ionscale";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l8l7zH146M3+kEy7nl4pRFDJjzmz8hf0MJ+G3BYYSbA=";
  };

  vendorHash = "sha256-87Ef2idpQ0Jnm+uYS6r3yMcrakiDAXkOitOaXUDdRo8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jsiebens/ionscale/internal/version.Version=${finalAttrs.version}"
  ];

  doCheck = false;

  meta = {
    description = "A lightweight implementation of a Tailscale control server";
    homepage = "https://jsiebens.github.io/ionscale/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ionscale";
  };
})
