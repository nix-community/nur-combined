{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "fd4a688df89207abdabe0a0cf5b2cd9ccfd376d2";
    hash = "sha256-YgMIIF9DAjyAPpZJtVoOKSatNhRPg/nPOYr0P06Fi5s=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-AZx9tPzsPvjc5kpmiBa6eYKtrw0hczYi0sbcd/lkiiA=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
