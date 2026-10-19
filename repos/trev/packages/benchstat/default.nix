{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "benchstat";
  version = "0-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "be2c69fb417e05de5fec05c732911f4c5f172606";
    hash = "sha256-Ura+yZPbWLQDB/R+OTSrUpKZtEjDvpitdpabKgDSm2M=";
  };

  vendorHash = "sha256-caW4rox/r2eq0HxACaAsuDLAeGIKUiLgKtJol8OXzDE=";

  subPackages = [ "cmd/benchstat" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=master"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Computes statistical summaries and A/B comparisons of Go benchmarks";
    mainProgram = "benchstat";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    changelog = "https://github.com/golang/perf/commits/master";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
})
