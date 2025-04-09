{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-instrument";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "nikolaydubina";
    repo = "go-instrument";
    rev = "v${version}";
    hash = "sha256-d0dUvXouYqbb0Pm8j1tcKHJlURZot+bBBEtKqTRzODI=";
  };

  vendorHash = "sha256-BIzeNT9UGHR1318NC83ptT92JUet/5Pjz/zBHL7PR9Y=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Automatically add Trace Spans to Go methods and functions";
    homepage = "https://github.com/nikolaydubina/go-instrument";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alanpearce ];
    mainProgram = "go-instrument";
  };
}
