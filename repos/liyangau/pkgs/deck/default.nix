{ pkgs, buildGoModule, lib, installShellFiles, fetchFromGitHub }:
let
  short_hash = "27c7d1b";
in
buildGoModule rec {
  pname = "deck";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "sha256-fZ0JmIkXTjS+5v9SszkBt/HHvf73Hzu4G/5f6c/eZtg=";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "${
    if pkgs.stdenvNoCC.isDarwin
    then "sha256-2QKFMcSjlcfc2VyteEQ282TlbS2xmP+26Vx98cnZHiQ="
    else "sha256-nt/mz+WcWo0Su6KCdOEOcHEztCoITlXTIIL9pfAdHo0="
  }";

  passthru.updateScript = ./update.sh;

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = with lib; {
    description = "A configuration management and drift detection tool for Kong";
    homepage = "https://github.com/Kong/deck";
    license = licenses.asl20;
    maintainers = with maintainers; [ liyangau ];
  };
}
