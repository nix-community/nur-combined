{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "2c532d1ed12c3553878373c446d24f781d82355c";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-NOgHE4RkmcD6MdOlCCGcT2raKGQI/5r2Dorr4gOzuX8=";
  };
  vendorHash = "sha256-cGXqMqEkq+X5/zMY0jEFK6El67pG8cI7/ZNswol7Tk8=";
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
