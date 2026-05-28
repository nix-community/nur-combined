{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (final: {
  pname = "palgen";
  version = "1.7.2-unstable-2026-05-28";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = final.pname;
    rev = "81f35d44df66ab8352532bb8a42d403294a9f691";
    hash = "sha256-dYN4mCtYP1Gvn0gZvcb2UyEcPWw+WG0/83afuh4B3FQ=";
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
