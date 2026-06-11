{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-06-10";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "712aea8b47053b2e77c04820a5032254b347cf96";
    hash = "sha256-NA6V4sHZlvHCfdV2758IoMrDFAszmfrTjszZ+HB+PbM=";
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
