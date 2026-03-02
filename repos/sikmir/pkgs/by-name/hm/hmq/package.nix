{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hmq";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "fhmq";
    repo = "hmq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tOp2HPv+iTmmuSd3d8sMfMRQNy+IJrwPtgfO2Zz+Acg=";
  };

  vendorHash = "sha256-oTzSCT2vYBYPQAQHBD0exmtuHZUxomf22XZlpECWllM=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "High performance mqtt broker";
    homepage = "https://github.com/fhmq/hmq";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "hmq";
  };
})
