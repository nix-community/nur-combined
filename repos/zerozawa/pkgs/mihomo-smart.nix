{
  lib,
  fetchFromGitHub,
  buildGoModule,
}: let
  rev = "be4113a445b648c07a9cb5087b4e7dcde9eb92fd";
in
  buildGoModule rec {
    pname = "mihomo-smart";
    version = "2025.10.15-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "vernesong";
      repo = "mihomo";
      inherit rev;
      hash = "sha256-Tamsr5/QssDIK+84GFxK57wK9FbC8+DKV7SdVlp180k=";
    };

    vendorHash = "sha256-wO7yCXAOYsFIskJo58xv/s5U4QiLi6iJItXoQOHhXjQ=";

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
