{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-i0fiN1cjMPwbWLFZgFqhS39DcvviENC+isr2WYiE3NQ=";

  modRoot = "frontend";

  meta = {
    changelog = "https://github.com/xddxdd/bird-lg-go/releases/tag/v${version}";
    mainProgram = "frontend";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
}
