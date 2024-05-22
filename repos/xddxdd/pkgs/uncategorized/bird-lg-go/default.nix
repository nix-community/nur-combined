{
  buildGoModule,
  lib,
  sources,
  ...
}:
buildGoModule rec {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-+M9Mlqck2E/ETW+NXsKwIeWlmZAaBU07fgDhKUU9PAI=";

  modRoot = "frontend";

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3Only;
  };
}
