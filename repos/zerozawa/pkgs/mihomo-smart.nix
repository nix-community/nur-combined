{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "301022fdcbcf2e988a84deda6d57b8448d975d00";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-Fa7/48hJ8rb72CCLZAUozbLzacIuLkoJYMiLHUcj6mU=";
  };
  vendorHash = "sha256-sEp8aOobO4MKw/tpENUZ7FMqOaTgbCFpQG7KqKmsAxQ=";
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
