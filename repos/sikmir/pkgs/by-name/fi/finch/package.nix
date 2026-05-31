{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.17.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AjJqFs7j2arXZR/m/AmWJP7QexHTtEjipsZjTpXql64=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-gZPda7f3LCSJKiQMy+5VP+yXOqjWUtJQ0ditaOa5sHs=";

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
