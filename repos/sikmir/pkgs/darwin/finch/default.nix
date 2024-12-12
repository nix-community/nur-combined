{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-6W5FVDPkW0Ei0q+biXyfPKGedLcVovWxlDyvG5BYfg0=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-CBeD9p9nzoGTGYnFnrz8s/wx6SSyXN5KfunD/IdcnNA=";

  subPackages = [ "cmd/finch" ];

  ldflags = [ "-X github.com/runfinch/finch/pkg/version.Version=${version}" ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  checkFlags = [ "-skip=TestVersionAction_run" ];

  meta = {
    description = "Client for container development";
    homepage = "https://github.com/runfinch/finch";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.darwin;
    skip.ci = true;
  };
}
