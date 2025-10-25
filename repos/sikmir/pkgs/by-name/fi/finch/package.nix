{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zkss73FHqwbOPDLJL1nLPw+GTkFt82lTZskqHbWxxaM=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-tTFH5f93o3rZdsDAnoYOZ6daMREI+RsxEKIG2zc1MSE=";

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
