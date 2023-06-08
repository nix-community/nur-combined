{ buildGoModule, lib, installShellFiles, fetchFromGitHub }:

buildGoModule rec {
  pname = "deck";
  version = "1.22.0";
  sha = "7447a09";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-BCx4bw+FrnH291sp52Dz+dc6cYtoLAt8fmdF6YbmgOE=";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${sha}"
  ];

  vendorSha256 = "sha256-rir8z1IwQenTvihHWaA7dx6Nn45M82ulCNRJuQlUhEM=";

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = with lib; {
    description =
      "decK provides declarative configuration and drift detection for Kong.";
    homepage = "https://github.com/Kong/deck";
    license = licenses.asl20;
  };
}
