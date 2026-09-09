{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "22c9c6c9d4da6248aedbc79f02ecedcd59f8f5f2";
    hash = "sha256-RSiI5I92l9bMWxTbHNKhcti4OKj8kD9yFxeHaWQJiFU=";
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
