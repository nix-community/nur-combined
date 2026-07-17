{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "solod";
  version = "0.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "solod-dev";
    repo = "solod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+uAHGurm/OZ7Nj91aVeIiMAYPMjDTcxjwA1ullnfkOg=";
  };

  vendorHash = "sha256-NIoEiLEb/p5kGQzYibPW9PI28tG3hjrqkLGs4TpSFxA=";

  subPackages = [
    "cmd/so"
    "cmd/inspect"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A subset of Go that translates to C";
    homepage = "https://github.com/solod-dev/solod";
    license = lib.licenses.bsd3;
    mainProgram = "so";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
