{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "6a80483318c964efe400c92565038335c0c80e41";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-sXCi17b3GqAP1IhdJnso2c77lgdqPESv2XfjBkvADQ0=";
  };
  vendorHash = "sha256-JLK4X3Uzepg+9n7QxiooTkqFOUkxgHVuwv3T1Xq+28I=";
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
    description = "Another Mihomo Kernel.";
    homepage = "https://github.com/vernesong/mihomo";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
