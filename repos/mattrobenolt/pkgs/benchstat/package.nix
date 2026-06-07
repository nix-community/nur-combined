{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "3cf34090a3db6bb64df2259e30021db7ff5d9595";
    hash = "sha256-2dz8GCzmyS8LkN1zzyCO8cn/NBKmPhIqFRfILc9/lVo=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-H9aP7PGzq5gmFvlYrkrOFfqCSdlpoQkIkTwKMgwr2hs=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
