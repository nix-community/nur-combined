{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "2e80ed75289c43da119c8f1fc8d022d0cdbc7f07";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-7+jNqGHhgtRf54yGt+nYQCHslXsr5mgul01PHDj0gX0=";
  };
  vendorHash = "sha256-ARwXdPz1TwQMg+cvQqQvnwufLjVOfg6GzARgYRuXzEw=";
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
