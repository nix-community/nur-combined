{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "e79b9645f3add8cf6b43b4ed0484a06df353ccb0";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-9KWVpFgRfbXFsuhcUEsmMnvlwqPEgPidDmtpDyjBIQA=";
  };
  vendorHash = "sha256-t8/Zpbl3IqowG+PgUX/E8bRSbzpjhgZeBT8+hOyLmy4=";
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
