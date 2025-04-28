{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-MAR+4o+BKd24uOpgcwsfMWoKWbRYxrCG6tMCrH8LS7Y=";

  modRoot = "proxy";

  meta = {
    mainProgram = "proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
}
