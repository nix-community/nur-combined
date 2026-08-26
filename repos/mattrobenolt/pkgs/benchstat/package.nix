{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "19be9d8e6c701dc8ccabaad34bf705f773fd398b";
    hash = "sha256-CimaQbwjQ5SMl/VTzuMeSciOp7aSomGbT/iyEsguOCg=";
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
