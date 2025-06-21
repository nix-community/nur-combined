{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-x6qIUEKeetEIrI40F6IBItM1HA1lIiDBv0Y6SrABTNE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-zlfeiyxEHLw4ABGrCznzJXUIZOqrOaAvci4ajdej8qI=";

  subPackages = [ "cmd/finch" ];

  ldflags = [ "-X github.com/runfinch/finch/pkg/version.Version=${version}" ];

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
}
