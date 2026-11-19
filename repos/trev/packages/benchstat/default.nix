{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "benchstat";
  version = "0-unstable-2026-11-17";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "4febdb082b2ce2a0f9f6f496698aa5a2273279b8";
    hash = "sha256-nHcqLEsIkT6GaF42hKsgGcoqCFgHY8bmPf5kdccjVE8=";
  };

  vendorHash = "sha256-wJDyOBQ6aoOSv81QjCj+sUSeFkyvTnbNQLmG4H3eyDs=";

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
