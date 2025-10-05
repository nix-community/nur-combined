{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "brink";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "jsiebens";
    repo = "brink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MXFqZY4ffSNyspoHqlGJ4kBm1eESyFoi1LzssEdNfos=";
  };

  vendorHash = "sha256-nb5+eRCQr465wpKxtS5rWVPNlmE4TUsPfSOTBiphqBo=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jsiebens/brink/internal/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "A lightweight Identity-Aware Proxy (IAP) for TCP forwarding";
    homepage = "https://github.com/jsiebens/brink";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "brink";
  };
})
