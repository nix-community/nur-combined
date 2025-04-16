{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-luJuIZ0xN8mdtWwTlfEDnAwMgt+Tzxlk2ZIDPIwHpcY=";

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
