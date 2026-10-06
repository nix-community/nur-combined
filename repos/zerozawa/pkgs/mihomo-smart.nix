{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "c3b2cb5fdf868964c1fddd0ba58e1e070f19bf28";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-VbYv75ObC9DTX7Qq5rbQwpdsjz0U9NuPoR0BJ3R8LTo=";
  };
  vendorHash = "sha256-oqRXW/pgqjX8wzfulfd7pB8c4RfI2CDRxbZ3hOW4SFY=";
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
