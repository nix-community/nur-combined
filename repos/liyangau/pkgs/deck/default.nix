{
  pkgs,
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}: let
  short_hash = "da7aa1d";
in
  buildGoModule rec {
    pname = "deck";
    version = "1.32.1";

    src = fetchFromGitHub {
      owner = "Kong";
      repo = "deck";
      rev = "v${version}";
      hash = "sha256-7lE/Wnrlv3L6V1ex+357q6XXpdx0810m1rKkqITowXY=";
    };

    nativeBuildInputs = [installShellFiles];

    CGO_ENABLED = 0;

    ldflags = [
      "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
      "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
    ];

    vendorHash = "${
      if pkgs.stdenvNoCC.isDarwin
      then "sha256-wjrfEsKY9eZWbjzDT3f5Dz60T2nYBuzF+cGwcwBQHXE="
      else "sha256-RlC22RNhzr/3gNPJYuXf3jqDhSy6T6KnQAm35gJ4p4Y="
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
      maintainers = with maintainers; [liyangau];
    };
  }
