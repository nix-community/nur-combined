{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "834a5063461e39359b5caf0caa609c75f7d72060";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-Xo0jG2wJvqm1qn2f6JFMxaxzWBLFaxTARGTBk3NHB4Y=";
  };
  vendorHash = "sha256-fKeir+RnlRgsWbTB++N5qDQgcwdVgmRPZHMX9rgIp40=";
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
