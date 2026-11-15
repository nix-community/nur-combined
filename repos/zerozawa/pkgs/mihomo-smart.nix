{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "c4df732a2c00731ea1a7c414500d161f5810f20e";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-5Qx/fo37M2dB5iCoI9oknV5hAexC2n6CMq7OVFMKOFk=";
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
