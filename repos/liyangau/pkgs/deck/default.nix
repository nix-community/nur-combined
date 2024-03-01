{
  pkgs,
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}: let
  short_hash = "0190a88";
in
  buildGoModule rec {
    pname = "deck";
    version = "1.35.0";

    src = fetchFromGitHub {
      owner = "Kong";
      repo = "deck";
      rev = "v${version}";
      hash = "sha256-Cng1T/TjhPttLFcI3if0Ea/M2edXDnrMVAFzAZmNAD8=";
    };

    nativeBuildInputs = [installShellFiles];

    CGO_ENABLED = 0;

    ldflags = [
      "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
      "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
    ];

    vendorHash = "${
      if pkgs.stdenvNoCC.isDarwin
      then "sha256-b3w2dMvyOukdQ1I7TcPOOut/xPFRjgFvzpmwHLwI0gA="
      else "sha256-a8uq7FasZl3D+tF1BqZwdp2d18CjHr5hucuOkxUwOOI="
    }";

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
    };
  }
