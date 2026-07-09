{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "benchstat";
  version = "unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "perf";
    rev = "82a0b07e230d76fa1b3036c383d7a98172f87334";
    hash = "sha256-TOzEoIWofdWlAfKWBS5KWxVpHsn2wx6GZDjACxFZiKI=";
  };

  subPackages = [ "cmd/benchstat" ];

  vendorHash = "sha256-PBvMccuMBBGfJlETw0Xjm5Ojkgg1BS+y9Kc3vwGW5kk=";

  meta = with lib; {
    description = "Compute and compare statistics about benchmark results";
    homepage = "https://pkg.go.dev/golang.org/x/perf/cmd/benchstat";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "benchstat";
  };
}
