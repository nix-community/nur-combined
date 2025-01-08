{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "finch";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    tag = "v${version}";
    hash = "sha256-t9JyGixJdKTd/dWzaZCIn4dqZO9QCamyrjsnmVA3LIo=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-X4cUMgLM1gbppaOU31mEoXSg1gxd5Rp1NYH85HJLhTg=";

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
