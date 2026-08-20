{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "ebcb4798430da1bb6761f0a1c8921251caba88de";
    hash = "sha256-TnhDd7IIYoa7JWyrFl5v9wxlXrR2levYUj15Ob1tKYo=";
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
