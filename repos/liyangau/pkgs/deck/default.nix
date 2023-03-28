{ buildGoModule, lib, installShellFiles, fetchFromGitHub }:

buildGoModule rec {
  pname = "deck";
  version = "1.19.1";
  sha = "0d80472";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname ;
    rev = "v${version}";
    sha256 = "sha256-ao3SGtHwDH+1zTYAzeN37cRNLjCaSFULkXOxLTKTvxc=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${sha}"
  ];

  vendorSha256 = "sha256-xFynhV1z3+8K613pFxoVxxQeG1N+rV8/gzkpy9MPF/0=";

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
