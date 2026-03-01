{
  lib,
  fetchFromGitHub,
  buildGoModule,
}: let
  rev = "b905b638cfd55eb8a7f584a2761022415671db22";
in
  buildGoModule rec {
    pname = "mihomo-smart";
    version = "0-unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "vernesong";
      repo = "mihomo";
      inherit rev;
      hash = "sha256-43cPPD5kaYPvEWn+/IUbkDrKP7eSNnu276zvUTB4D8E=";
    };

    vendorHash = "sha256-ugqh2EyaFeMWMRuZRYLa8ZGChKghKg4t2qZatpkS/h0=";

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
