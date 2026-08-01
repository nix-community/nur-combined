{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "25b8ce3b368194086733be8a3a58f1086a8ced4c";
in
buildGoModule rec {
  pname = "mihomo-oix";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo-oix";
    inherit rev;
    hash = "sha256-+CdPqdj0TDMM9Vr+mMxR+gr894cOoYjVjtHAnP9M8FU=";
  };
  vendorHash = "sha256-6+Q0vFD4IH7acIcjH/iIK819CCAoDiTJ/wGkEu4FoOU=";
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
    mv $out/bin/mihomo $out/bin/mihomo-oix
  '';

  meta = with lib; {
    description = "A rule-based tunnel in Go with LightGBM smart routing (fork of mihomo)";
    homepage = "https://github.com/vernesong/mihomo-oix";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
