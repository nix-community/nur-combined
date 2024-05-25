{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "ionscale";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "jsiebens";
    repo = "ionscale";
    rev = "v${version}";
    hash = "sha256-D6w5mHjlz+P+h0Q/8kk0PIDyyDfQxPsVka13ZTTDuv0=";
  };

  vendorHash = "sha256-YULdxUTzI+lwy9/wrSSc/rv3vwBkGkNc0b9GyUc9jQc=";

  ldflags = [ "-X github.com/jsiebens/ionscale/internal/version.Version=${version}" ];

  doCheck = false;

  meta = {
    description = "A lightweight implementation of a Tailscale control server";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ionscale";
  };
}
