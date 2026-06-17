{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "3a617ec0f2c7a0dda7e37602dfca0175fc9f8ec2";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-xe06CCrci3Haq2Pb7tJe10NR4IyIEVTRzF15uqpBQ04=";
  };

  vendorHash = "sha256-G2O1u1+Fj4FwJyVgOdrlwQ10hT1XNCMsqQglq/hFnjg=";

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
