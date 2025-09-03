{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "terraform-graph-beautifier";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "pcasteran";
    repo = "terraform-graph-beautifier";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+IuZOgnxYVR3X7RQbXbrOvfQVJ02+UYedvq+A3WaSS4=";
  };

  vendorHash = "sha256-UZmZ7xCzuq8/B5C4x4Ti7/v1BW1AH4cDxFrORuaIqAY=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";
  doInstallCheck = true;

  meta = {
    description = "Terraform graph beautifier";
    homepage = "https://github.com/pcasteran/terraform-graph-beautifier";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "terraform-graph-beautifier";
  };
})
