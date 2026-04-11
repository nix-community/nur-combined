{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "solod";
  version = "0-unstable-2026-04-08";

  src = fetchFromGitHub {
    owner = "solod-dev";
    repo = "solod";
    rev = "fece3b7c42c1aa64344ebeb129ad2133656a57c8";
    hash = "sha256-EpZCQiaLeaW80ht+QquE3z43U56TabYF/2RBWsTrUlY=";
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
