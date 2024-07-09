{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    rev = "v${version}";
    hash = "sha256-LtVW1HAi2oDx1MbsFnzHLZkBuYoGQs0dQU2HiWD7gB4=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-7opa7lW606VZkCJR0ezzfzaPIpBsbnSoA/6I0GaPAoM=";

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
