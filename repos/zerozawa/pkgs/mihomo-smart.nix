{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "daf3ad03021cca6031f4a7303ca6d861a14d5a16";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-B81Gf100cixywBXxJASq/k8cgNweLzN6QCZd0BLHrtc=";
  };
  vendorHash = "sha256-HtYAYyv+z3cKOJ7avTMUyb7Gz+qo/BpyTPLeqlkXL3I=";
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
