{
  lib,
  buildGo124Module,
  fetchFromGitHub,
  alsa-lib,
}:

buildGo124Module rec {
  pname = "sektron";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "emprcl";
    repo = "sektron";
    rev = "v${version}";
    hash = "sha256-3cZYAsWLKN0508wysQ7dKSlOzZxRPSk3B6ak0SUCDGE=";
  };

  buildInputs = [ alsa-lib ];

  patches = [ ./gomidi.patch ];

  vendorHash = "sha256-syHdQG8cc5QhMLdcxIt1V1CxdAEZZa0zTVmjG7Cm2zY=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A midi step sequencer in the terminal, made with live performance in mind :loop";
    homepage = "https://github.com/emprcl/sektron";
    license = lib.licenses.mit;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "sektron";
  };
}
