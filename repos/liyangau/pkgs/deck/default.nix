{ buildGoModule, lib, installShellFiles, fetchFromGitHub }:

buildGoModule rec {
  pname = "deck";
  version = "1.21.0";
  sha = "735fbe2";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname ;
    rev = "v${version}";
    sha256 = "sha256-q6ImnIrBdl1ZoB1fEMhGzudpVgNGO0jeHG7EDt/q9xY=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${sha}"
  ];

  vendorSha256 = "sha256-HB3hI288H3X1O9/24Xhe6ymA7px7CRgnmFEeLsMDVeE=";

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = with lib; {
    description = "decK provides declarative configuration and drift detection for Kong.";
    homepage    = "https://github.com/Kong/deck";
    license     = licenses.asl20;
  };
}
