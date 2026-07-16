{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.17.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tHIkFeBLWNmpZfAmyCINL5HFSaMDbFxuGJ5mqtKqRK4=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-TQtukQnGAm0oEA+ZleBQ4bm4rNsvJqiyLKe4wfZe+C0=";

  subPackages = [ "cmd/finch" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/runfinch/finch/pkg/version.Version=${finalAttrs.version}"
  ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [ "-skip=TestVersionAction_run" ];

  meta = {
    description = "Client for container development";
    homepage = "https://github.com/runfinch/finch";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.darwin;
    skip.ci = true;
  };
})
