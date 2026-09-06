{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "4bc3d49f8d82f292d2176ddc4156aca57c287122";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-nLuyGGmm6KqZr1J3Rk05NlMou5qrlNGmglofVZWxxp0=";
  };
  vendorHash = "sha256-E5rEF3w5Lihv4gBKLl95iM9PGECTJto0fIpXp4SbGyw=";
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
