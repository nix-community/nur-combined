{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule (finalAttrs: {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-9BpsRIIidBEm+ivwFIo00H9MTH4R3kkze/W/HaH8124=";

  modRoot = "proxy";

  meta = {
    mainProgram = "proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
})
