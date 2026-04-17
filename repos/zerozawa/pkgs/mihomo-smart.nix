{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "bc21da0dc7f65f34329804b43fe74a9483a8a6f2";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-af7gtCaZMS/6TIaIJ/+/gH01Q8eE0jY1JD6IaoDM+Ss=";
  };

  vendorHash = "sha256-mEyEIJTFlmSMR619ffrb7W5Y5L519qdVv2i7nSQ81rw=";

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
