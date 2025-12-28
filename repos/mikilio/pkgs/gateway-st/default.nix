{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "gateway-st";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "storj";
    repo = "gateway-st";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XTcwDktYHuebhrZxAyM9VRwlyYiCSXNRl7HSG0wZVYY=";
  };

  subPackages = [
    "."
  ];

  vendorHash = "sha256-HPLpM4p0pJOAorYLjldggVxzXG1635tqHU6SUdWmrIE=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-X storj.io/common/version.buildTimestamp=0"
    "-X storj.io/common/version.buildCommitHash=${finalAttrs.src.rev}"
    "-X storj.io/common/version.buildVersion=${finalAttrs.version}"
    "-X storj.io/common/version.buildRelease=true"
  ];

  meta = {
    description = "Single-tenant, S3-compatible server to interact with the Storj network ";
    homepage = "https://github.com/storj/gateway-st";
    license = lib.licenses.asl20;
  };
})
