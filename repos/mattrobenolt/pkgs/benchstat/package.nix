{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "be2c69fb417e05de5fec05c732911f4c5f172606";
    hash = "sha256-Ura+yZPbWLQDB/R+OTSrUpKZtEjDvpitdpabKgDSm2M=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-caW4rox/r2eq0HxACaAsuDLAeGIKUiLgKtJol8OXzDE=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
