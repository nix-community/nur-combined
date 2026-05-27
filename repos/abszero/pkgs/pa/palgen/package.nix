{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (final: {
  pname = "palgen";
  version = "1.7.0-unstable-2026-04-25";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = final.pname;
    rev = "97218961a46dc6432c6d784c34800da34f4f8dc3";
    hash = "sha256-pGtpjRnebUT8eNC2tZswNi4CDwhtyexBC3cFCF2jjGY=";
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
