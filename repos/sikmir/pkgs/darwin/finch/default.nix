{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    rev = "v${version}";
    hash = "sha256-u8/i81jB2HGXeft1X+AQ0wblo2bHa412EQXGmgN5afQ=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-QAB+TVi7A34ANpEaVSGQF5qm7ORhcbVvBYK8SixCzTk=";

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
