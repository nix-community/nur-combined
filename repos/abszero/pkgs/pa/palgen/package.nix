{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (final: {
  pname = "palgen";
  version = "1.7.3-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = final.pname;
    rev = "b9d6ebb9e994eaaba96a1246b03ffde5cb2b9f3e";
    hash = "sha256-2MtcQ7ChNTfSNIc4e07TWr0zxN9AuzD/a4clUq8SRk4=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Convert png to palettes in various formats";
    homepage = "https://github.com/xyproto/palgen";
    license = licenses.bsd3;
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
  };
})
