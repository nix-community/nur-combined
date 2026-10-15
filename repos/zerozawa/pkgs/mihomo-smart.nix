{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "83e67d0c4415b1114f9e01d8e9a00133caf89f6c";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-vYBu+Lz7OqPgWIdpIb9Dm+tdPiSsJB9WlCtRcpdtw7M=";
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
