{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "2379047490c7b354182951b97e1747bde7c2838f";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-kRwO92LEwfOMaaixtdyWq+tAT1mCNbBc2QOfLk7PFno=";
  };
  vendorHash = "sha256-Rp77ZeYahzeW6WvByTKjNy0J+CeU1jmeLYyjy/y8YiY=";
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
