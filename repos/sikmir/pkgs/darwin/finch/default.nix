{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-zfcRDFFEyS+cvF06f2JlV4Hj6EBQUdWHJX3GPuK1B/o=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-iR2SvX5QohdZo9tAcu7S86opVjnMx4mFQSAe8Vhd/og=";

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
