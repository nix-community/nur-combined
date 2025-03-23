{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ksuid";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "segmentio";
    repo = "ksuid";
    rev = "v${finalAttrs.version}";
    hash = "sha256-50molk1vt8/n4Y+ruayW/EAn9NeeQ8ApmLJQVePhieE=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "K-Sortable Globally Unique IDs";
    homepage = "https://github.com/segmentio/ksuid";
    license = lib.licenses.mit;
    mainProgram = "ksuid";
  };
})
