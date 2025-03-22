{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-GHYst+/nMkBCqYDXq6kUVfj6xm1IhONV1uGHcBsz3dc=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-fy02OnAq6dMVoYc+wKQlhGZmX+TaFWNWmM5MQCkbpfo=";

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
