{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "4b88a15cd0ba5bd3e3f2c8dfcf764eba179fdeb2";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-A5msS+d53FhwP5DHVQz0gtDmThzpze5aT9VjOhDl3Bs=";
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
