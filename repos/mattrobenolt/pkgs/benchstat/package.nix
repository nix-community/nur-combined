{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-09-29";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "406019bb8b6893dd1245d31bf511c719619bb5c9";
    hash = "sha256-R0Gu3giMeJKbDNT1LcKCOZTznoc1wGYCxmvt+dA5mhM=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-9y6O/R2fOPYAGjlIZ2lcO1TNiZPj6My3EoPRiiFZu3U=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
