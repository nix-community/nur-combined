{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "3e709f6320897150a8aeb6adeb52ca6d4f4bf164";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-zHrGpOpSaGGAkMDcVUqntiNzi0NFDkOt7Xfjk0OQMxM=";
  };
  vendorHash = "sha256-2bwNZmIu0k3cYtv0b8wY9J2nLHPCVprkQr+AgrM+ESo=";
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
