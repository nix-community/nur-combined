{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "9e4b9ddef5b6a4371594ec978cb4b8088bec845d";
    hash = "sha256-q03UUW5fJPLd6UicH+q2KEC9sx3Ph64ebzi4sxW4+rg=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-qGQpf0T1qBcu+25VF2xnbvImj+Fs81Ru9tho/0RJwzo=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
