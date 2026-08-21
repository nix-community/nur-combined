{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.18.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zVbVgseHvAsqd2arF8Z/XZeRunmDzrLZRlj3cchDjcw=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-ycKN778qJq395j8Snwt4rLF3NhLP+9V2hwVxOujyVqg=";

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
