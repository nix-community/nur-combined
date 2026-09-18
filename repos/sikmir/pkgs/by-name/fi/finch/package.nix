{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.19.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4X0Bg7FNkIATVay7dpMjhGWrCl2SBpL7NrwlGUS5wMM=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-Jpxxb5UFlJcs3tNkmelljq8bpCzxjwCfhSOQ81V1Mk8=";

  subPackages = [ "cmd/finch" ];

  ldflags = [
    "-s"
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
