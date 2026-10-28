{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "ea99c1511bf6e9293530f519ddf346b235dce5df";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-UmiuKmOwcKhbqspAwkU9jCHZRC5oi6YqrNYpGVZDnHg=";
  };
  vendorHash = "sha256-koNPc+P0yf7JGEnnGTVHxeHLHz7n87RoQt3Wl4RNl18=";
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
