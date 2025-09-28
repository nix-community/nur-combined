{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule (finalAttrs: {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-kNysGHtOUtYGHDFDlYNzdkCXGUll105Triy4UR7UP0M=";

  modRoot = "frontend";

  meta = {
    changelog = "https://github.com/xddxdd/bird-lg-go/releases/tag/v${finalAttrs.version}";
    mainProgram = "frontend";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
})
