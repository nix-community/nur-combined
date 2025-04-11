{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "cbor";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "fiatjaf";
    repo = "cbor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TuSpJdT3xvnUPzxFbjKFeTiuKmHDpqoQ2WaCIUPULWE=";
  };

  vendorHash = "sha256-6Oiqkau2nnZxbw0Gnfvr+ECzFRF8bMoCQTV3zXX0+/8=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Command line tool that turns CBOR into JSON or JSON into CBOR";
    homepage = "https://github.com/fiatjaf/cbor";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "cbor";
  };
})
