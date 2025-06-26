{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hmq";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "fhmq";
    repo = "hmq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vBsUDKrs7add8gFF6dMK5WK8irfWowCrRdB3N4Aegwg=";
  };

  vendorHash = "sha256-bmyFXI6OBddzvu6mJxI/TW3pRqq6w6LsDveBvUd10tk=";

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
