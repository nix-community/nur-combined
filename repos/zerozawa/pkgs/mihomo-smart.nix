{
  lib,
  fetchFromGitHub,
  buildGoModule,
}: let
  rev = "ca41c4a94111e3a5cd5d817fb8ab24c9c108085d";
in
  buildGoModule rec {
    pname = "mihomo-smart";
    version = "0-unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "vernesong";
      repo = "mihomo";
      inherit rev;
      hash = "sha256-iS2Qu4DRFh0IQjQ+W2M+aP03324jtYyZVN8YFobxbwQ=";
    };

    vendorHash = "sha256-xU/kVgvqoXltmaVJ5UDbpRR6Wq3p5ueohRfkGY8RnW4=";

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
