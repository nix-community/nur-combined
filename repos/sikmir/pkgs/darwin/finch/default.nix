{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-gu+qfpc1thn1bmKlWt/tc6fmaR4R/4FA7EOSv/Gv8gk=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-e1m/v7azULd8m0OfnZLDyHSnb8xBVJ+9CHHnHltG7Ek=";

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
