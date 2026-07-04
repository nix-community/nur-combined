{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "8591cb80ce3b81b6f6f1cebe4c81c3ef76cd4a46";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-YcKXX0rQ9sQokI6/KGamxzBh9/GpWXbyKzasX6yzLss=";
  };
  vendorHash = "sha256-Bttq1x1BxWBFuB7hN8vjVdRGno1Samd8YBcp3yNojs4=";
  excludedPackages = [ "./test" ];

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
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
