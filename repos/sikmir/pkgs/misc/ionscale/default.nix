{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "ionscale";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "jsiebens";
    repo = "ionscale";
    tag = "v${version}";
    hash = "sha256-i0b+08wh1Z1gspkTz/Bbh8CSe8Sqd7UsiBnMofA1dh8=";
  };

  vendorHash = "sha256-xzHJ81mM+evqNBwYyYVHeRwtnepgFdqc/fgrMTgkQPE=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jsiebens/ionscale/internal/version.Version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "A lightweight implementation of a Tailscale control server";
    homepage = "https://jsiebens.github.io/ionscale/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ionscale";
  };
}
