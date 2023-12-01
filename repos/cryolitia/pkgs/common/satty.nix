{ rustPlatform
, fetchFromGitHub
, pango
, glib
, cairo
, libadwaita
, gtk4
, gdk-pixbuf
, pkg-config
, fetchpatch
, lib
}:

rustPlatform.buildRustPackage rec {

  pname = "satty";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Cryolitia";
    repo = "satty";
    rev = "a970abae05ee951cbad2c068f73c89111bda1ca6";
    sha256 = "sha256-dEDcvTIflLxOxwRf8576Clf31MRb6CBYbBoyFQ/7v1c=";
  };

  buildInputs = [
    pango
    glib
    cairo
    libadwaita
    gtk4
    gdk-pixbuf
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  cargoSha256 = "sha256-0GsbWd/gpKZm7nNXkuJhB02YKUj3XCrSfpRA9KBXydU=";

  meta = with lib; {
    description = "Modern Screenshot Annotation.";
    homepage = "https://github.com/gabm/satty";
    license = licenses.mpl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "satty";
  };

}
