{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "finch";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lvB0JtzJruTkLhEdcOCVpRuisKJVtKbfYRvHJw1IVv8=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-hd3dzHXShyoa5LZqHlP7zoha36N9k11qzS6Z7wr7pDY=";

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
