{
  lib,
  fetchFromGitHub,
  buildGoModule,
}: let
  rev = "211858122ad3154dede8fef61a7f0f13502a1802";
in
  buildGoModule rec {
    pname = "mihomo-smart";
    version = "0-unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "vernesong";
      repo = "mihomo";
      inherit rev;
      hash = "sha256-4xB+vJlVZQhjj39pCa4iT2Fi7MvfB48Qwj3LPCGEHNQ=";
    };

    vendorHash = "sha256-ONucZMQgOwQ8iiHOlfgdppdPKxY3CdkbUnavkiCnYi0=";

    excludedPackages = ["./test"];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/metacubex/mihomo/constant.Version=${version}"
    ];

    tags = [
      "with_gvisor"
    ];

    # network required
    doCheck = false;

    postInstall = ''
      mv $out/bin/mihomo $out/bin/mihomo-smart
    '';

    meta = with lib; {
      description = "A rule-based tunnel in Go with Smart Groups functionality (fork of mihomo)";
      homepage = "https://github.com/vernesong/mihomo";
      license = licenses.gpl3Only;
      mainProgram = pname;
      platforms = platforms.all;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
