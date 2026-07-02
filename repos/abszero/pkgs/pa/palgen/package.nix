{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (final: {
  pname = "palgen";
  version = "1.7.3-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = final.pname;
    rev = "0d2ad3ccfdb6a2ec58f997c2e34acf7b907c3f8d";
    hash = "sha256-0qpXSXKXfHmdg6zz1OwlTMfX/JNaqC/F+zx18CXS/gI=";
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
