{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-11-17";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "4febdb082b2ce2a0f9f6f496698aa5a2273279b8";
    hash = "sha256-nHcqLEsIkT6GaF42hKsgGcoqCFgHY8bmPf5kdccjVE8=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-wJDyOBQ6aoOSv81QjCj+sUSeFkyvTnbNQLmG4H3eyDs=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
