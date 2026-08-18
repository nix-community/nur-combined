{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "5664b1ba0943206e0fa140eb0f31f393688b0c2d";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-rG4aFkOMRKJy8mnKGiQ3B+03MmLbpaOfLJoTs+Fb/JY=";
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
