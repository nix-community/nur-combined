{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "1f152749f097c68e8e7288fc6e806c21f45e279c";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-ugqlq3TdRM6PXOcojAjMZVmtyEXGaZZcweMwNaO1SMo=";
  };
  vendorHash = "sha256-I2QZei6tVGS8Nazbf6eakBj/jDr7Qi4UKZ5yKlp2C2g=";
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
