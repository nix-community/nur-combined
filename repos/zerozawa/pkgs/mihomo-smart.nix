{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "06ec497250069f336f91ca9fcdf6b22486d7347a";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-9wQmxdwMg1myxytIKQNKP+uOREDvD2NlwQXAr5y/Atg=";
  };
  vendorHash = "sha256-1MTrXO3GeyngE+5achA+R9CD57ZHbuRKm6vLWMazsBU=";
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
