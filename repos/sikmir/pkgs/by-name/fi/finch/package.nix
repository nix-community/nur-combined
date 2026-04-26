{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.17.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FPGCBsnsUFBS1KpCYFlhTY+s67Xf2eSU+04R38QBWnc=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-5BVFwgE19w/9gAI5wNvHbmQQf6ydfKOJ9Z+CMMxUv4g=";

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
