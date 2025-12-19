{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (final: {
  pname = "palgen";
  version = "1.6.1-unstable-2025-05-06";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = final.pname;
    rev = "760ed3d06e46de5452da99297b7bd83c197288c5";
    hash = "sha256-6khn66pUg52J9UDHvsM5+dNn49ZmOH/n2arccYsirX8=";
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
